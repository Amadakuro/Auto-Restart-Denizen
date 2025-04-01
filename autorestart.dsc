Auto_Restart_Check:
  type: world
  debug: false
  events:
    on server start:
      - if !<server.has_flag[AutoRestartTime]>:
        - flag server AutoRestartTime:05:00
      - if !<server.has_flag[AutoRestartWarnTime]>:
        - flag server AutoRestartWarnTime:04:00
      - if !<server.has_flag[AutoRestart]>:
        - flag server AutoRestart:enabled
      - if !<server.has_flag[AutoRestartTriggered]>:
        - flag server AutoRestartTriggered:false
    on delta time minutely:
      - if <server.flag[AutoRestart]> != enabled:
        - stop
      - define current_time:<util.time_now.format[HH:mm]>
      - if <[current_time]> == <server.flag[AutoRestartWarnTime]>:
        - announce "<&c>Внимание: сервер перезагрузится через 1 час. Пожалуйста, сохраните свои ресурсы!"
      - if <[current_time]> == <server.flag[AutoRestartTime]>:
        - if !<server.flag[AutoRestartTriggered]>:
          - if <server.has_flag[RestartActive]>:
            - stop
          - announce "<&5><&l>O<&5><&l>r<&5><&l>j<&5><&l>u<&5><&l>s<&f><&l>R<&f><&l>E<&f><&l>S<&f><&l>T<&f><&l>A<&f><&l>R<&f><&l>T<&8> ❯❯<reset> <&c>Авторестарт сервера начнется через 30 секунд..."
          - flag server AutoRestartTriggered:true
          - run Auto_Restart_Delay
      - else:
        - flag server AutoRestartTriggered:false

Auto_Restart_Delay:
  type: task
  debug: false
  script:
    - if <server.has_flag[RestartActive]>:
      - narrate "<&c>Рестарт уже в процессе, подождите завершения."
      - stop
    - flag server RestartInProgress:!
    - flag server RestartActive duration:40s
    - define times:20|10|5|4|3|2|1
    - foreach <[times]> as:time:
      - if <[time]> == 20:
        - wait <[time]>s
        - announce "<&5><&l>O<&5><&l>r<&5><&l>j<&5><&l>u<&5><&l>s<&f><&l>R<&f><&l>E<&f><&l>S<&f><&l>T<&f><&l>A<&f><&l>R<&f><&l>T<&8> ❯❯<reset><&c> Рестарт через 20 секунд..."
      - else if <[time]> == 10:
        - wait 10s
        - announce "<&5><&l>O<&5><&l>r<&5><&l>j<&5><&l>u<&5><&l>s<&f><&l>R<&f><&l>E<&f><&l>S<&f><&l>T<&f><&l>A<&f><&l>R<&f><&l>T<&8> ❯❯<reset><&c> Рестарт через 10 секунд..."
      - else:
        - wait 1s
        - if <[time]> == 1:
          - define suffix "у"
        - else if <[time]> in 2|3|4:
          - define suffix "ы"
        - else:
          - define suffix ""
        - announce "<&5><&l>O<&5><&l>r<&5><&l>j<&5><&l>u<&5><&l>s<&f><&l>R<&f><&l>E<&f><&l>S<&f><&l>T<&f><&l>A<&f><&l>R<&f><&l>T<&8> ❯❯<reset><&c> Рестарт через <[time]> секунд<[suffix]>..."
    - announce "<&5><&l>O<&5><&l>r<&5><&l>j<&5><&l>u<&5><&l>s<&f><&l>R<&f><&l>E<&f><&l>S<&f><&l>T<&f><&l>A<&f><&l>R<&f><&l>T<&8> ❯❯<reset><&c> Сервер перезапускается сейчас!"
    - wait 1s
    - execute as_server "stop"

Auto_Restart_Command:
  type: command
  debug: false
  name: autorestart
  description: Управляет авторестартом сервера
  usage: /autorestart enable disable status manual settimes gui
  permission: autorestart.admin
  tab_completions:
    1: enable|disable|status|manual|settimes|gui
  script:
    - if <context.args.is_empty>:
      - narrate "<&5><&l>ОШИБКА <&8>❯❯ <&c>Неверная команда!"
      - narrate "<&8>➥ <&f>Используйте: <&e>/autorestart <&f>аргумент"
      - narrate "<&8>➥ <&f>Доступные аргументы:"
      - narrate "<&8>  ➥ <&e>enable <&8>- <&f>Включить авторестарт"
      - narrate "<&8>  ➥ <&e>disable <&8>- <&f>Отключить авторестарт"
      - narrate "<&8>  ➥ <&e>status <&8>- <&f>Показать состояние"
      - narrate "<&8>  ➥ <&e>manual <&8>- <&f>Ручной рестарт"
      - narrate "<&8>  ➥ <&e>settimes <&8>- <&f>Установить время"
      - narrate "<&8>  ➥ <&e>gui <&8>- <&f>Открыть GUI"
      - stop
    - define arg:<context.args.get[1]>
    - if <[arg]> == enable:
      - flag server AutoRestart:enabled
      - narrate "Авторестарт включен."
    - else if <[arg]> == disable:
      - flag server AutoRestart:disabled
      - narrate "Авторестарт отключен."
    - else if <[arg]> == status:
      - narrate "Состояние авторестарта: <server.flag[AutoRestart]>"
      - narrate "Рестарт в: <server.flag[AutoRestartTime]>"
      - narrate "Предупреждение в: <server.flag[AutoRestartWarnTime]>"
    - else if <[arg]> == manual:
      - narrate "<&5><&l>O<&5><&l>r<&5><&l>j<&5><&l>u<&5><&l>s<&f><&l>R<&f><&l>E<&f><&l>S<&f><&l>T<&f><&l>A<&f><&l>R<&f><&l>T<&8> ❯❯<reset><&c> Ручной рестарт сервера начнется через 30 секунд..."
      - run Auto_Restart_Delay
    - else if <[arg]> == settimes:
      - if <context.args.size> < 3:
        - narrate "<&5><&l>ОШИБКА <&8>❯❯ <&c>Недостаточно аргументов!"
        - narrate "<&8>➥ <&f>Используйте: <&e>/autorestart settimes <&f>рестарт HH:MM <&f>предупреждение HH:MM"
        - narrate "<&8>➥ <&f>Пример: <&e>/autorestart settimes 05:00 04:00"
        - stop
      - define restart_time:<context.args.get[2]>
      - define warn_time:<context.args.get[3]>
      - define restart_hours:<[restart_time].split[:].get[1].if_null[invalid]>
      - define restart_minutes:<[restart_time].split[:].get[2].if_null[invalid]>
      - define warn_hours:<[warn_time].split[:].get[1].if_null[invalid]>
      - define warn_minutes:<[warn_time].split[:].get[2].if_null[invalid]>
      - if <[restart_hours]> == invalid || <[restart_minutes]> == invalid || <[restart_time].split[:].size> != 2:
        - narrate "<&5><&l>ОШИБКА <&8>❯❯ <&c>Неверный формат времени рестарта!"
        - narrate "<&8>➥ <&f>Используйте: <&e>HH:MM"
        - narrate "<&8>➥ <&f>Пример: <&e>05:00"
        - stop
      - if <[warn_hours]> == invalid || <[warn_minutes]> == invalid || <[warn_time].split[:].size> != 2:
        - narrate "<&5><&l>ОШИБКА <&8>❯❯ <&c>Неверный формат времени предупреждения!"
        - narrate "<&8>➥ <&f>Используйте: <&e>HH:MM"
        - narrate "<&8>➥ <&f>Пример: <&e>04:00"
        - stop
      - if <[restart_hours].is_integer.not> || <[restart_hours]> < 0 || <[restart_hours]> > 23:
        - narrate "<&5><&l>ОШИБКА <&8>❯❯ <&c>Часы рестарта вне диапазона!"
        - narrate "<&8>➥ <&f>Должно быть числом от 0 до 23."
        - stop
      - if <[restart_minutes].is_integer.not> || <[restart_minutes]> < 0 || <[restart_minutes]> > 59:
        - narrate "<&5><&l>ОШИБКА <&8>❯❯ <&c>Минуты рестарта вне диапазона!"
        - narrate "<&8>➥ <&f>Должно быть числом от 0 до 59."
        - stop
      - if <[warn_hours].is_integer.not> || <[warn_hours]> < 0 || <[warn_hours]> > 23:
        - narrate "<&5><&l>ОШИБКА <&8>❯❯ <&c>Часы предупреждения вне диапазона!"
        - narrate "<&8>➥ <&f>Должно быть числом от 0 до 23."
        - stop
      - if <[warn_minutes].is_integer.not> || <[warn_minutes]> < 0 || <[warn_minutes]> > 59:
        - narrate "<&5><&l>ОШИБКА <&8>❯❯ <&c>Минуты предупреждения вне диапазона!"
        - narrate "<&8>➥ <&f>Должно быть числом от 0 до 59."
        - stop
      - define restart_time_formatted:<[restart_hours].pad_left[2].with[0]>:<[restart_minutes].pad_left[2].with[0]>
      - define warn_time_formatted:<[warn_hours].pad_left[2].with[0]>:<[warn_minutes].pad_left[2].with[0]>
      - flag server AutoRestartTime:<[restart_time_formatted]>
      - flag server AutoRestartWarnTime:<[warn_time_formatted]>
      - narrate "Время рестарта установлено на <server.flag[AutoRestartTime]>"
      - narrate "Предупреждение установлено на <server.flag[AutoRestartWarnTime]>"
    - else if <[arg]> == gui:
      - run Auto_Restart_GUI_Open def:<player>
    - else:
      - narrate "<&5><&l>ОШИБКА <&8>❯❯ <&c>Неизвестный аргумент '<[arg]>'!"
      - narrate "<&8>➥ <&f>Используйте: <&e>/autorestart <&f>аргумент"
      - narrate "<&8>➥ <&f>Доступные аргументы:"
      - narrate "<&8>  ➥ <&e>enable <&8>- <&f>Включить авторестарт"
      - narrate "<&8>  ➥ <&e>disable <&8>- <&f>Отключить авторестарт"
      - narrate "<&8>  ➥ <&e>status <&8>- <&f>Показать состояние"
      - narrate "<&8>  ➥ <&e>manual <&8>- <&f>Ручной рестарт"
      - narrate "<&8>  ➥ <&e>settimes <&8>- <&f>Установить время"
      - narrate "<&8>  ➥ <&e>gui <&8>- <&f>Открыть GUI"

Auto_Restart_GUI_Open:
  type: task
  debug: false
  script:
    - define inv <inventory[generic[size=9;title=<&e>Control_Panel]]>
    - flag server active_gui:<[inv]>
    - define enable_item <item[emerald_block].with[display=<&2>Включить авторестарт;lore=Нажмите для включения;flag=gui_action:enable]>
    - define disable_item <item[redstone_block].with[display=<&c>Отключить авторестарт;lore=Нажмите для отключения;flag=gui_action:disable]>
    - define manual_item <item[clock].with[display=<&e>Ручной рестарт;lore=Нажмите для рестарта;flag=gui_action:manual]>
    - inventory set d:<[inv]> o:air slot:1
    - inventory set d:<[inv]> o:<[enable_item]> slot:2
    - inventory set d:<[inv]> o:air slot:3
    - inventory set d:<[inv]> o:air slot:4
    - inventory set d:<[inv]> o:<[disable_item]> slot:5
    - inventory set d:<[inv]> o:air slot:6
    - inventory set d:<[inv]> o:air slot:7
    - inventory set d:<[inv]> o:<[manual_item]> slot:8
    - inventory set d:<[inv]> o:air slot:9
    - inventory open d:<[inv]>

Auto_Restart_GUI_Handler:
  type: world
  debug: false
  events:
    on player clicks item in inventory:
      - if <context.inventory.inventory_type> != CHEST:
        - stop
      - if <context.inventory> != <server.flag[active_gui]>:
        - stop
      - define action <context.item.flag[gui_action]||none>
      - if <[action]> == enable:
        - flag server AutoRestart:enabled
        - narrate "Авторестарт включен."
        - inventory close
        - flag server active_gui:!
      - else if <[action]> == disable:
        - flag server AutoRestart:disabled
        - narrate "Авторестарт отключен."
        - inventory close
        - flag server active_gui:!
      - else if <[action]> == manual:
        - narrate "<&c>Ручной рестарт через 30 секунд..."
        - run Auto_Restart_Delay
        - inventory close
        - flag server active_gui:!
      - determine cancelled