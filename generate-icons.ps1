# generate-icons.ps1 — draws the COIN QUEST app icon: an 8-bit pixel-art octopus.
# A 16x16 pixel map is rendered, then scaled up with nearest-neighbor (no
# smoothing) so the pixels stay crisp at every size.
# Background is transparent (no navy square) and the sprite is cropped to its
# tight bounding box, then scaled to fill the icon while keeping its aspect.
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$dir = $PSScriptRoot

# 16x16 pixel map.  legend:
#   . transparent   X dark outline
#   B body (purple)   D darker body / tentacle tips
#   W eye white       K pupil
$MAP = @(
  '................',
  '.....XXXXXX.....',
  '...XXBBBBBBXX...',
  '..XBBBBBBBBBBX..',
  '.XBBBBBBBBBBBBX.',
  '.XBBBBBBBBBBBBX.',
  '.XBBWWBBBBWWBBX.',
  '.XBBWKBBBBKWBBX.',
  '.XBBBBBBBBBBBBX.',
  '.XBBBBBBBBBBBBX.',
  '.XBBBBBBBBBBBBX.',
  '.XBBBBBBBBBBBBX.',
  '.BB.BB.BB.BB.BB.',
  '.DD.DD.DD.DD.DD.',
  '................',
  '................'
)

$COLORS = @{
  'X' = '#7a4f00'  # outline (dark bronze)
  'B' = '#ffd23f'  # body (gold)
  'D' = '#c98a00'  # shade / tentacle tips (deep gold)
  'W' = '#ffffff'  # eye white
  'K' = '#3a2400'  # pupil
}
# build the crisp 16x16 source sprite on a transparent background, and find the
# tight bounding box of the actual sprite pixels (everything that isn't '.')
$src = New-Object System.Drawing.Bitmap(16, 16)
$minX = 16; $minY = 16; $maxX = -1; $maxY = -1
for ($y = 0; $y -lt 16; $y++) {
  $row = $MAP[$y]
  for ($x = 0; $x -lt 16; $x++) {
    $ch = $row[$x]
    if ($ch -ne '.') {
      $src.SetPixel($x, $y, [System.Drawing.ColorTranslator]::FromHtml($COLORS["$ch"]))
      if ($x -lt $minX) { $minX = $x }
      if ($x -gt $maxX) { $maxX = $x }
      if ($y -lt $minY) { $minY = $y }
      if ($y -gt $maxY) { $maxY = $y }
    }
  }
}
$bw = $maxX - $minX + 1   # bounding-box width  (sprite pixels)
$bh = $maxY - $minY + 1   # bounding-box height

function New-Icon($size, $path) {
  $bmp = New-Object System.Drawing.Bitmap($size, $size)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.Clear([System.Drawing.Color]::Transparent)
  $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
  $g.PixelOffsetMode   = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
  $g.SmoothingMode     = [System.Drawing.Drawing2D.SmoothingMode]::None

  # fit the cropped sprite into ~92% of the icon, keeping its aspect ratio, centred
  $inner = $size * 0.92
  $scale = $inner / [Math]::Max($bw, $bh)
  $drawW = [int]([Math]::Round($bw * $scale))
  $drawH = [int]([Math]::Round($bh * $scale))
  $offX  = [int][Math]::Round(($size - $drawW) / 2)
  $offY  = [int][Math]::Round(($size - $drawH) / 2)
  $dst = New-Object System.Drawing.Rectangle($offX, $offY, $drawW, $drawH)
  $g.DrawImage($src, $dst, $minX, $minY, $bw, $bh, [System.Drawing.GraphicsUnit]::Pixel)

  $g.Dispose()
  $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
  $bmp.Dispose()
  Write-Host "  $path ($size x $size)"
}

Write-Host "Generating octopus icons..."
New-Icon 512 (Join-Path $dir 'icon-512.png')
New-Icon 192 (Join-Path $dir 'icon-192.png')
New-Icon 180 (Join-Path $dir 'apple-touch-icon.png')
New-Icon 32  (Join-Path $dir 'favicon-32.png')
$src.Dispose()
Write-Host "Done."
