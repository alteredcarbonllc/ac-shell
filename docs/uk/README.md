# Altered Carbon Shell (`ac-shell`)

**Мова:** [English](../../README.md) · Українська · [Русский](../ru/README.md)

Відтворюване **користувацьке середовище командної оболонки Ubuntu**, побудоване за результатами аудиту ноутбука Altered Carbon (30 жовтня 2026 року). Інсталятор написано на переносимому `sh`; оболонка — Zsh з Oh My Zsh та запрошенням Starship.

**Стан:** публічний кандидат на перший реліз. Повний тест встановлення успішно пройдено у QEMU/KVM із чистою Ubuntu 24.04 (`LAB_VM_PASS`). Офлайн-тести синтаксису та регресії пройшли в [GitHub Actions #1](https://github.com/alteredcarbonllc/ac-shell/actions/runs/41141291341) для Ubuntu 22.04, 24.04 та 26.04. CI поки **не перевіряє повне мережеве встановлення**. Інші ОС не підтримуються. Це інсталятор користувацької оболонки, **не** система початкового налаштування чи розгортання серверів.

## Встановлення однією командою (після першого релізу)

Виконуйте від звичайного користувача Ubuntu з правом `sudo`; не запускайте сам інсталятор від root:

```sh
sudo apt-get update && sudo apt-get install -y curl && curl -fL --proto '=https' --tlsv1.2 -o ac-shell-setup.sh https://raw.githubusercontent.com/alteredcarbonllc/ac-shell/v0.1.0/ac-shell-setup.sh && sh ac-shell-setup.sh install --set-default-shell
```

**`v0.1.0` — лише запланований тег, реліз іще не опубліковано.** Після випуску фіксуйте тег або точний commit SHA, щоб завантажуваний скрипт не змінювався непомітно. Перед запуском перегляньте `ac-shell-setup.sh`. Після зміни login shell увійдіть знову; `exec zsh` запускає нову оболонку лише в поточному терміналі.

Для встановлення найновіших стабільних компонентів **під час першого встановлення** використовуйте `sh ac-shell-setup.sh install --latest --set-default-shell`. Цей режим отримує останній стабільний Starship і актуальні ревізії Oh My Zsh та плагінів, після чого зберігає точні версії. Повторний запуск нічого автоматично не оновлює; для production використовуйте зафіксовані перевірені версії.

Якщо репозиторій уже клоновано:

```sh
sh test-shell.sh
sh ac-shell-setup.sh plan
sh ac-shell-setup.sh install --set-default-shell
sh ac-shell-setup.sh verify
```

Деталі: [Встановлення](INSTALL.md), [Безпека](SECURITY.md), [Журнал розробки](DEVELOPMENT_HISTORY.md), [Підготовка релізу](RELEASE.md), [Лабораторія](lab/README.md).

## Відтворені можливості

- Zsh + Oh My Zsh з **фактично активними** плагінами: `git`, `zsh-autosuggestions`, `zsh-syntax-highlighting`.
- Starship з `format = '$hostname$time$all'`: блакитна назва хоста, жовті дата й час `ДД.ММ.РРРР ГГ:ХХ:СС`, стандартні модулі Git/Python/тривалості команди за наявності контексту; зелена стрілка `➜`, дворядкове запрошення; модуль package вимкнений.
- `HISTSIZE=50000`, `SAVEHIST=10000`, `HIST_IGNORE_DUPS`, `SHARE_HISTORY`, `EXTENDED_HISTORY`, `AUTO_CD`; `CORRECT` вимкнено.
- Пакети Zsh/Git та допоміжні утиліти `fzf`, `zoxide`, `ripgrep`, `fd-find`, `mosh`. Непідтверджені інтеграції fzf/zoxide **не активуються**. Неактивний на ноутбуці плагін `you-should-use` не включено.
- Особисті псевдоніми, секрети, додаткові підключені скрипти, файли шрифтів та системна версія Python **не копіюються**.

Назва хоста, каталог, версія Python і точний вигляд символів залежать від конкретної машини та шрифту термінала.

## Структура проєкту

```text
ac-shell-setup.sh                    Інсталятор POSIX sh: plan / install / verify / render
test-shell.sh                        Офлайн-регресійні тести
test-docs.py                         Перевірка перекладів і посилань
lab/run-local-user-lab.sh           Тест під окремим користувачем
lab/ac-shell-vm-lab.sh              Ізольована лабораторія QEMU/KVM Ubuntu 24.04
.github/workflows/offline-tests.yml Офлайн-CI для Ubuntu 22.04/24.04/26.04
```

## Ліцензія

Власний код проєкту поширюється за **MIT License**: [канонічний текст англійською](../../LICENSE). Сторонні компоненти мають власні ліцензії; репозиторій не змінює їхні умови.
