# Epistemics

Separate direct evidence from inference.

## Confidence

- High: the source states the reason directly, such as a PR description, ticket, incident, or design document.
- Medium: multiple independent sources support the same explanation, but none states it plainly.
- Low: the explanation follows only from code shape, timing, or absence of alternatives.

Use precise language: "the PR says" for direct evidence, "this suggests" for supported inference, and "we cannot tell" when the record is missing. Cite every claim with a commit, PR, ticket, document, chat permalink, metric query, or file and line.

Do not treat implementation mechanics as proof of intent. Report contradictions and empty searches. Keep competing hypotheses when the evidence does not distinguish them.
