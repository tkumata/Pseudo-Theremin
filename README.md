# 幼児向けなんちゃってテルミン

## 説明

前面カメラで環境光輝度を取得し、現状いい加減な方法で周波数へ変換。この周波数を元に正弦波の音を鳴らします。例えば、前面カメラに手などで影を作ると音が変わります。

- [x] 輝度取得
- [x] 正弦波の音を出す
- [x] 輝度と音を連動させる(※)
- [ ] 動的な音量変更
- [ ] カメラデバイス取得 (.devices()) の完全な Swift3 対応
- [ ] 音だけじゃなくて画面も変えたらいいかも？
- [ ] 幼児が好む色って...um

※周波数が変わるたびに AudioEngine を .stop() させているため音が連続しません。.stop() させないと、

- SIGABRT で落ちる
- 音が一切変わらない

という問題があるためひとまず .stop() させてバッファを作り直しています。難儀しています。


## License

MIT


## Author

tkumata