#!/usr/bin/env bash
# Source is https://github.com/nikitabobko/AeroSpace/issues/296

APP_ID=$1
APP_NAME=$2

focus_app() {
  current_workspace=$(aerospace list-workspaces --focused)
  app_window_id=$(aerospace list-windows --all --format "%{window-id}%{right-padding} | %{app-name}" | grep $APP_NAME | cut -d' ' -f1 | sed '1p;d')
  aerospace focus --window-id $app_window_id
  aerospace move-node-to-workspace $current_workspace
  aerospace workspace $current_workspace
  aerospace move-mouse window-lazy-center
}

app_closed() {
  if [ "$(aerospace list-windows --all --format '%{app-name}' | grep $APP_NAME)" == "" ]; then
    true
  else
    false
  fi
}

app_focused() {
  if [ "$(aerospace list-windows --focused --format "%{app-bundle-id}")" == "$APP_ID" ]; then
    true
  else
    false
  fi
}

unfocus_app() {
  aerospace move-node-to-workspace 1
}

if app_closed; then
  open -a $APP_NAME
  sleep 0.5
else
  if app_focused; then
    unfocus_app
  else
    focus_app
  fi
fi