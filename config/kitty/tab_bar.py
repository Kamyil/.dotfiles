from os.path import basename

from kitty.fast_data_types import wcswidth
from kitty.rgb import color_as_int
from kitty.tab_bar import TabAccessor, as_rgb


COLORS = {
  'bar_bg': 0x2A2A37,  # sumiInk4
  'session_bg': 0xAE6966,
  'session_fg': 0xE6E6E3,  # canvasWhite5
  'active_bg': 0x9E7E98,  # canvasPink1
  'active_fg': 0x1D1C19,  # dragonBlack2
  'inactive_bg': 0x1D1C19,  # dragonBlack2
  'inactive_fg': 0xCBC8BC,  # canvasWhite1
  'muted_fg': 0x8E8A80,  # canvasGray2
  'attention_fg': 0xAE6966,
}

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

SHELLS = {'bash', 'fish', 'nu', 'sh', 'zsh'}
RIGHT_SEP = ''


def _set_colors(screen, fg, bg):
  screen.cursor.fg = as_rgb(fg)
  screen.cursor.bg = as_rgb(bg)


def _draw_segment(screen, text, fg, bg, right=True):
  _set_colors(screen, fg, bg)
  screen.draw(text)
  if right:
    _set_colors(screen, bg, COLORS['bar_bg'])
    screen.draw(RIGHT_SEP)


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


def _active_session_name(tab):
  return tab.active_session_name or tab.session_name or 'default'


def draw_tab(draw_data, screen, tab, before, max_tab_length, index, is_last, extra_data):
  screen.cursor.bold = False
  screen.cursor.italic = False

  if index == 1:
    session = _trim(_active_session_name(tab), 22)
    _draw_segment(screen, f' 󰆍 {session} ', COLORS['session_fg'], COLORS['session_bg'])
    screen.draw(' ')

  bg = COLORS['active_bg'] if tab.is_active else COLORS['inactive_bg']
  fg = COLORS['active_fg'] if tab.is_active else COLORS['inactive_fg']

  icon = _icon(tab)
  title = _title(tab)
  prefix = f' {index}:{icon} '
  suffix = ' '
  available = max(1, max_tab_length - (screen.cursor.x - before) - wcswidth(prefix) - wcswidth(suffix) - 2)
  text = prefix + _trim(title, available) + suffix

  if tab.needs_attention:
    text = f' !{text.lstrip()}'
    fg = COLORS['attention_fg']

  _draw_segment(screen, text, fg, bg)

  if not is_last:
    screen.draw(' ')

  screen.cursor.bg = as_rgb(COLORS['bar_bg'])
  screen.cursor.fg = as_rgb(color_as_int(draw_data.inactive_fg))
  return screen.cursor.x
