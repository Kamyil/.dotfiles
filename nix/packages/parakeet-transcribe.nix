{
  lib,
  fetchzip,
  fetchurl,
  ffmpeg,
  coreutils,
  sherpa-onnx,
  writeShellApplication,
}:

let
  model = fetchzip {
    url = "https://github.com/k2-fsa/sherpa-onnx/releases/download/asr-models/sherpa-onnx-nemo-parakeet-tdt-0.6b-v3-int8.tar.bz2";
    hash = "sha256-3zMIAaTYBJZB8rXgaxHZdgBqBbrrLLN7USLH+JNTaDY=";
    stripRoot = true;
  };
  sileroVad = fetchurl {
    url = "https://github.com/k2-fsa/sherpa-onnx/releases/download/asr-models/silero_vad.onnx";
    hash = "sha256-niRJ4Qh0ltjUyrqQfyPgvT942R+lUkebucI6wJy7H9Y=";
  };
in
writeShellApplication {
  name = "parakeet-transcribe";
  runtimeInputs = [
    coreutils
    ffmpeg
    sherpa-onnx
  ];
  text = ''
    if (( $# < 1 || $# > 2 )); then
      echo "Usage: parakeet-transcribe AUDIO_FILE [OUTPUT_FILE]" >&2
      exit 2
    fi

    input=$1
    if [[ ! -f "$input" ]]; then
      echo "Audio file does not exist: $input" >&2
      exit 1
    fi

    output="''${2:-''${input%.*}.txt}"
    wav=$(mktemp --suffix=.wav)
    trap 'rm -f "$wav"' EXIT

    ffmpeg -hide_banner -loglevel error -y -i "$input" -vn -ac 1 -ar 16000 -c:a pcm_s16le "$wav"

    result=$(sherpa-onnx-vad-with-offline-asr \
      --silero-vad-model=${sileroVad} \
      --silero-vad-threshold=0.2 \
      --silero-vad-min-speech-duration=0.2 \
      --encoder=${model}/encoder.int8.onnx \
      --decoder=${model}/decoder.int8.onnx \
      --joiner=${model}/joiner.int8.onnx \
      --tokens=${model}/tokens.txt \
      --model-type=nemo_transducer \
      --num-threads="''${PARAKEET_THREADS:-$(nproc)}" \
      "$wav")

    transcript=$(
      while IFS= read -r line; do
        if [[ "$line" =~ ^[[:digit:].]+[[:space:]]--[[:space:]][[:digit:].]+:[[:space:]](.*)$ ]]; then
          printf '%s\n' "''${BASH_REMATCH[1]}"
        fi
      done <<< "$result"
    )
    if [[ -z "$transcript" ]]; then
      echo "Parakeet did not return a transcript." >&2
      printf '%s\n' "$result" >&2
      exit 1
    fi

    printf '%s\n' "$transcript" > "$output"
    echo "Saved transcript: $output"
  '';

  meta = {
    description = "Transcribe local audio with Parakeet TDT 0.6B v3 using sherpa-onnx";
    license = [
      lib.licenses.asl20
      lib.licenses.cc-by-40
    ];
    platforms = lib.platforms.linux;
    mainProgram = "parakeet-transcribe";
  };
}
