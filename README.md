# suapt

Чуть удобная версия `apt`, которая автоматически запускается
от рута.

Вот все команды:
| Команда | Описание |
|---------|----------|
| `-version` | версия `suapt` |
| `-su` | версии возможных програм, через которые команды выполняются от рута |
| `i`, `install`, `add` | `apt install`, без аргументов запускает `apt update` и `apt upgrade` |
| `rm`, `remove`, `de`, `dd`, `del`, `delet`, `delete` | `apt remove`, без аргументов запускает `apt autoremove` |
| `pg`, `pu`, `pr`, `purge` | `apt purge`, без аргументов запускает `apt autopurge` |
| `l`, `ls`, `lst`, `list` | `apt list`, не от рута |
| `se`, `search` | `apt search`, не от рута |
| `up`, `update` | `apt update` |
| `upg`, `upgrade` | `apt upgrade` |
| `inf`, `info`, `sh`, `show` | `apt show`, не от рута |
| `rei`, `reinstall` | `apt reinstall` |
| `autopurge`, `autopg`, `autopr` | `apt autopurge` |
| `autorm`, `autoremove` | `apt autoremove` |

Все неизвесные аргументы, к примеру `suapt --version` выполняются от
рута.

## Установка

Два способа: скачать `suapt.bash` и кинуть его в `$PATH`, в `/usr/bin` к примеру. `chmod +x suapt.bash` и впринципе готово.

Второй способ: скачать его, кинуть куда угодно и написать в `.bashrc`:
`INCLUDE=1 source /path/to/suapt.bash`

На случай, если у вас рыба (fish), можно написать в файл
`~/.config/fish/functions/suapt.fish` это:

```fish
function suapt
  command $HOME/.local/bin/suapt.bash $argv
  return $status
end
```

Так же кинуть `suapt.bash` в `~/.local/bin/suapt.bash`

