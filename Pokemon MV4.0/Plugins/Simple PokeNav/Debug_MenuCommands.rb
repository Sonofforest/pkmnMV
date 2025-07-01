MenuHandlers.add(:debug_menu, :toggle_pokenav, {
  "name"        => _INTL("Dar Pokenav"),
  "parent"      => :player_menu,
  "description" => _INTL("Cambia la posesión del Pokenav."),
  "effect"      => proc {
    $player.has_pokenav = !$player.has_pokenav
    pbMessage(_INTL("Dio Pokénav.")) if $player.has_pokenav
    pbMessage(_INTL("Quito Pokénav.")) if !$player.has_pokenav
  }
})