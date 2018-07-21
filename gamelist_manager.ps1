$doc = [xml] (Get-Content -raw gamelist.xml)

foreach ($gameEl in $doc.DocumentElement.game) { 
  # Use -replace to extract the filename without extension from the 
  # path contained in the <path> element.
  $gameName = $gameEl.path -replace '^.*/(.*)\..*$', '$1'
  # Append elements 'video' and 'marquee', but only if they don't already
  # exist.
  if ($null -eq $gameEl.video) {
    $gameEl.AppendChild($doc.CreateElement('video')).InnerText = "./videos/${gameName}.mp4"
  }
  if ($null -eq $gameEl.marquee) {
    $gameEl.AppendChild($doc.CreateElement('marquee')).InnerText = "./marquees/${gameName}.png"
  }
}
rename-item gamelist.xml -newname oldgamelist.xml
$writer = [System.IO.StreamWriter] "gamelist.xml"
$doc.Save($writer)
$writer.Close()
