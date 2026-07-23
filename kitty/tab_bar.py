import json
from os import stat
from os.path import basename, expanduser

from kitty.fast_data_types import wcswidth
from kitty.rgb import color_as_int
from kitty.tab_bar import TabAccessor, as_rgb


COLORS = {
  'bar_bg': 0x141416,
  'active_fg': 0xC4B28A,
  'inactive_fg': 0x9E9B93,
  'muted_fg': 0x8E8A80,  # canvasGray2
  'attention_fg': 0xC4746E,
}

THEME_FILE = expanduser('~/.local/state/dotfiles-theme/current/theme.json')
_theme_mtime = None


def _refresh_colors():
  global _theme_mtime
  try:
    mtime = stat(THEME_FILE).st_mtime_ns
    if mtime == _theme_mtime:
      return
    with open(THEME_FILE, encoding='utf-8') as theme_file:
      palette = json.load(theme_file)
    COLORS.update({
      'bar_bg': int(palette['tab_bar'][1:], 16),
      'active_fg': int(palette['yellow'][1:], 16),
      'inactive_fg': int(palette['muted'][1:], 16),
      'muted_fg': int(palette['muted'][1:], 16),
      'attention_fg': int(palette['red'][1:], 16),
    })
    _theme_mtime = mtime
  except (OSError, KeyError, TypeError, ValueError, json.JSONDecodeError):
    pass

SHELLS = {'bash', 'fish', 'nu', 'sh', 'zsh'}

ICONS = {
  'bash': '',
  'btm': '',
  'docker': '',
  'fish': '',
  'git': '',
  'htop': '',
  'lazygit': '',
  'less': '󰈙',
  'nvim': '',
  'opencode': '󰚩',
  'python': '',
  'ssh': '󰣀',
  'sudo': '󰌾',
  'vim': '',
  'zsh': '',
}


def _set_colors(screen, fg, bg):
  screen.cursor.fg = as_rgb(fg)
  screen.cursor.bg = as_rgb(bg)


def _trim(text, width):
  if wcswidth(text) <= width:
    return text
  if width <= 1:
    return '…'

  out = ''
  for char in text:
    if wcswidth(out + char) >= width:
      break
    out += char
  return out + '…'


def _tab_accessor(tab):
  return TabAccessor(tab.tab_id) if tab.tab_id >= 0 else None


def _active_exe(tab):
  accessor = _tab_accessor(tab)
  if accessor is None:
    return ''
  return (accessor.active_exe or accessor.active_oldest_exe or '').lower()


def _directory_name(tab):
  accessor = _tab_accessor(tab)
  if accessor is None:
    return ''
  cwd = accessor.active_wd or accessor.active_oldest_wd or ''
  return basename(cwd.rstrip('/')) or '/'


def _title(tab):
  title = (tab.title or '').strip()
  session_name = (tab.session_name or tab.active_session_name or '').strip()
  exe = _active_exe(tab)
  directory = _directory_name(tab)

  if not title or title == session_name or title.lower() in SHELLS or title.lower() == exe:
    return directory or title or 'shell'
  return title


def _active_session_name(tab):
  return tab.active_session_name or tab.session_name or 'default'


def _icon(tab):
  exe = _active_exe(tab)
  title = (tab.title or '').lower()
  if 'opencode' in title:
    return ICONS['opencode']
  if exe in ICONS:
    return ICONS[exe]
  if exe.endswith('git'):
    return ICONS['git']
  if exe in SHELLS:
    return ICONS.get(exe, '')
  return '󰆍'


def draw_tab(draw_data, screen, tab, before, max_tab_length, index, is_last, extra_data):
  _refresh_colors()
  screen.cursor.bold = False
  screen.cursor.italic = False
  screen.cursor.bg = as_rgb(COLORS['bar_bg'])

  if index == 1:
    session = _trim(_active_session_name(tab), 22)
    _set_colors(screen, COLORS['inactive_fg'], COLORS['bar_bg'])
    screen.draw(f'[{session}] ')

  fg = COLORS['active_fg'] if tab.is_active else COLORS['inactive_fg']

  title = _title(tab)
  prefix = f'{index}:{_icon(tab)} '
  suffix = '*' if tab.is_active else ''
  available = max(1, max_tab_length - (screen.cursor.x - before) - wcswidth(prefix) - wcswidth(suffix) - 1)
  text = prefix + _trim(title, available) + suffix

  if tab.needs_attention:
    text = f'!{text}'
    fg = COLORS['attention_fg']

  _set_colors(screen, fg, COLORS['bar_bg'])
  screen.draw(text)

  if not is_last:
    screen.draw(' ')

  screen.cursor.bg = as_rgb(COLORS['bar_bg'])
  screen.cursor.fg = as_rgb(color_as_int(draw_data.inactive_fg))
  return screen.cursor.x
