[English](README.md)| [中文](README.zh.md) | Русский

# Nikkix

Прозрачный прокси с **Mihomo** на **OpenWrt**.

## Fork

Это форк проекта **Nikki**.
Оригинальный репозиторий: https://github.com/nikkinikki-org/OpenWrt-nikki

Изменения:

- Поддержка HWID
- Удаление китйских листов
- TPROXY по дефолту

## Требования

- OpenWrt >= 23.05
- Ядро Linux >= 5.13
- firewall4

## Возможности

- Прозрачный прокси (Redirect / TPROXY / TUN, IPv4 и/или IPv6)
- Контроль доступа
- Объединение профилей (Profile Mixin)
- Редактор профилей
- Плановый перезапуск
- Поддержка HWID

## Установка и обновление

### A. Установка из feed (рекомендуется)

#### 1. Добавление feed

```shell
# выполняется только один раз
wget -O - https://github.com/mglants/nikkix/raw/refs/heads/main/feed.sh | ash
```

#### 2. Установка

```shell
# можно установить из shell или через меню `Software` в LuCI
# для opkg
opkg install nikkix
opkg install luci-app-nikkix
opkg install luci-i18n-nikkix-ru

# для apk
apk add nikkix
apk add luci-app-nikkix
apk add luci-i18n-nikkix-ru
```

### B. Установка из релиза

```shell
wget -O - https://github.com/mglants/nikkix/raw/refs/heads/main/install.sh | ash
```

## Удаление и сброс настроек

```shell
wget -O - https://github.com/mglants/nikkix/raw/refs/heads/main/uninstall.sh | ash
```

## Как использовать

См. [Wiki](https://github.com/mglants/nikkix/wiki)

## Как это работает

1. Миксин и обновление профиля
2. Запуск mihomo
3. Настройка планового перезапуска
4. Настройка ip rule / route
5. Генерация nftables и их применение

> Примечание: последовательность шагов может меняться в зависимости от конфигурации.

## Сборка (Compilation)

```shell
# добавить feed
echo "src-git nikkix https://github.com/mglants/nikkix.git;main" >> "feeds.conf.default"

# обновить и установить feeds
./scripts/feeds update -a
./scripts/feeds install -a

# собрать пакет
make package/luci-app-nikkix/compile
```

Собранные пакеты будут находиться в каталоге:
`bin/packages/your_architecture/nikkix`.

## Зависимости

- ca-bundle
- curl
- yq
- firewall4
- ip-full
- kmod-inet-diag
- kmod-nft-socket
- kmod-nft-tproxy
- kmod-tun

## Участники

[![Участники](https://contrib.rocks/image?repo=nikkinikki-org/nikki)](https://github.com/nikkinikki-org/nikki/graphs/contributors)
[![Участники](https://contrib.rocks/image?repo=mglants/nikkix)](https://github.com/mglants/nikkix/graphs/contributors)

## Особая благодарность

- [@ApoisL](https://github.com/apoiston)
- [@xishang0128](https://github.com/xishang0128)


## Рекомендуемый провайдер прокси

Рекомендуется **Remnwave**.

Официальный сайт: https://docs.rw/
Служба поддержки: https://t.me/remnawave
