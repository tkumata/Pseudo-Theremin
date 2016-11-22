# 幼児向けなんちゃってテルミン

## 説明

iOS 端末の前面カメラで環境光の輝度を取得し、あくまでも現状では対数を取ることで音の可聴域周波数へ変換します。そして、この周波数を元に正弦波の音を鳴らします。例えば、前面カメラに手などで影を作ると音が変わります。手の位置を変えても音が変わります。ここがテルミン風です。自分の体の動きと音が連動するので、子供は喜ぶのではないかなあと思っています。

また、環境光ではなく、小さな (例えば指輪型) iBeacon 端末の RSSI と連動して音が変化するようにすれば、子供向けおもちゃになるのではないかと考えています。iBeacon 端末が売り物で、アプリは無料というような感じです。

なお、前面カメラさえあればいいので、機種変等で使わなくなった iOS 端末の有効利用にもなります。


## TODO

- [x] 輝度の取得
- [x] 正弦波の音を出す
- [x] 輝度と音を連動させる(※)
- [ ] 音量変更ボタンの有効化
- [x] カメラデバイス取得 (.devices()) の完全な Swift3 対応
- [ ] 音だけじゃなくて画面も変えたらいいかも？
- [ ] 幼児が好む色って...um

※周波数が変わるたびに Audio Player Node を .stop()/.play() させているため音が連続しません。ただし .stop() させないと、音が一切変わらないという問題があるためひとまず .stop() させてオーディオバッファを作り直しています。現在、回避策・改善策を模索中ですが、難儀しています。

[Demo MP4 file (2.2MB).](./IMG_0140.mp4)


## License

MIT


## Author

tkumata
