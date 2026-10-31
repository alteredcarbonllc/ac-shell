# Altered Carbon Shell (`ac-shell`)

**Язык:** [English](../../README.md) · [Українська](../uk/README.md) · Русский

Воспроизводимое **пользовательское окружение командной оболочки Ubuntu**, созданное на основе аудита ноутбука Altered Carbon (30 октября 2026 года). Установщик написан на переносимом `sh`; используются Zsh, Oh My Zsh и приглашение Starship.

**Статус:** версионированный Git-тег [`v0.1.0`](https://github.com/alteredcarbonllc/ac-shell/tree/v0.1.0) опубликован и испытан в одноразовой Ubuntu 24.04 VM; [GitHub Release](https://github.com/alteredcarbonllc/ac-shell/releases/tag/v0.1.0) уже опубликован. Полная проверка установки успешно выполнена в QEMU/KVM с чистой Ubuntu 24.04 (`LAB_VM_PASS`). Офлайн-тесты синтаксиса и регрессии прошли в [GitHub Actions #1](https://github.com/alteredcarbonllc/ac-shell/actions/runs/41141291341) на Ubuntu 22.04, 24.04 и 26.04. CI пока **не проверяет полную сетевую установку**. Другие ОС не поддерживаются. Это установщик пользовательской оболочки, **а не** система первичного развёртывания сервера.

## Установка одной командой (опубликованный тег v0.1.0)

Выполняйте от обычного пользователя Ubuntu с правом `sudo`; не запускайте сам установщик от root:

```sh
sudo apt-get update && sudo apt-get install -y curl ca-certificates && curl -fL --proto '=https' --tlsv1.2 -o ac-shell-v0.1.0.sh https://raw.githubusercontent.com/alteredcarbonllc/ac-shell/v0.1.0/ac-shell-setup.sh && printf '%s  %s\n' '4925bdcba07bea531442347d1bcaa8159f3c48c17435140517d0635632be41f9' ac-shell-v0.1.0.sh | sha256sum -c - && sh ac-shell-v0.1.0.sh install --set-default-shell
```

**`v0.1.0` — уже опубликованный аннотированный Git-тег** на коммите `b88ed432da8f1264d6c7ae712a542cf90e63076a`. Загруженный установщик побайтово сверен с тегом (SHA-256 `4925bdcba07bea531442347d1bcaa8159f3c48c17435140517d0635632be41f9`), отдельный пользователь VM завершил тест `RELEASE_TAG_LAB_PASS`. Полная однострочная команда с `--set-default-shell` / `chsh` **ещё не проверена**; login shell в VM менялся через `usermod`. Закрепляйте тег или SHA, чтобы скрипт не менялся незаметно. Закреплённая контрольная сумма SHA-256 остановит выполнение, если скачанный скрипт отличается от проверенного файла `v0.1.0`. Команду в `main` можно редактировать, но файлы исторического тега остаются неизменными. Перед запуском изучите `ac-shell-v0.1.0.sh`. После изменения login shell войдите заново; `exec zsh` запускает новую оболочку только в текущем терминале.

Для установки новейших стабильных компонентов **при первой установке** используйте `sh ac-shell-v0.1.0.sh install --latest --set-default-shell`. Режим получает последний стабильный релиз Starship и текущие ревизии Oh My Zsh/плагинов, после чего записывает точные версии. Повторный запуск автоматически ничего не обновляет; на production предпочтительнее зафиксированные проверенные версии.

Если репозиторий уже клонирован:

```sh
sh test-shell.sh
sh ac-shell-setup.sh plan
sh ac-shell-setup.sh install --set-default-shell
sh ac-shell-setup.sh verify
```

Подробнее: [Установка](INSTALL.md), [Безопасность](SECURITY.md), [История разработки](DEVELOPMENT_HISTORY.md), [Подготовка релиза](RELEASE.md), [Лаборатория](lab/README.md).

## Воспроизводимые возможности

- Zsh + Oh My Zsh с **фактически активными** плагинами: `git`, `zsh-autosuggestions`, `zsh-syntax-highlighting`.
- Starship с `format = '$hostname$time$all'`: голубой hostname, жёлтая дата и время `ДД.ММ.ГГГГ ЧЧ:ММ:СС`, стандартные модули Git/Python/длительности команды при наличии контекста; зелёная стрелка `➜`, двухстрочное приглашение; модуль package отключён.
- `HISTSIZE=50000`, `SAVEHIST=10000`, `HIST_IGNORE_DUPS`, `SHARE_HISTORY`, `EXTENDED_HISTORY`, `AUTO_CD`; `CORRECT` выключен.
- Пакеты Zsh/Git и вспомогательные утилиты `fzf`, `zoxide`, `ripgrep`, `fd-find`, `mosh`. Неподтверждённые интеграции fzf/zoxide **не активируются**. Неактивный на ноутбуке плагин `you-should-use` не включён.
- Личные алиасы, секреты, дополнительные подключаемые скрипты, локальные файлы шрифтов и системная версия Python **не копируются**.

Имя компьютера, каталог, версия Python и точное отображение символов зависят от конкретной машины и шрифта терминала.

## Структура проекта

```text
ac-shell-setup.sh                    Установщик POSIX sh: plan / install / verify / render
test-shell.sh                        Офлайн-регрессионные тесты
test-docs.py                         Проверка переводов и ссылок
lab/run-local-user-lab.sh           Тест под отдельным пользователем
lab/ac-shell-vm-lab.sh              Изолированная лаборатория QEMU/KVM Ubuntu 24.04
.github/workflows/offline-tests.yml Офлайн-CI для Ubuntu 22.04/24.04/26.04
```

## Лицензия

Собственный код проекта распространяется на условиях **MIT License**: [канонический английский текст](../../LICENSE). У сторонних компонентов свои лицензии, которые не изменяются этим репозиторием.
