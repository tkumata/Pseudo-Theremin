# 幼児向けなんちゃってテルミン

## 説明

iOS 端末の前面カメラで環境光の輝度を取得し、(あくまでも現状では)対数を取ることで可聴域周波数へ変換します。そして、この周波数を元に正弦波の音を鳴らします。例えば、前面カメラに手などで影を作ると音が変わります。手の位置を変えても音が変わります。ここがテルミン風です。自分の体の動きと音が連動するので、子供は喜ぶのではないかなあと思っています。

また、環境光ではなく、小さな (例えば指輪・腕輪型) iBeacon 端末の電波強度 (RSSI) と連動して音が変化するようにすれば、子供向けおもちゃになるのではないかと考えています。iBeacon 端末が売り物で、アプリは無料というような感じです。

なお、前面カメラさえあればいいので、iPod touch や Wi-Fi model な iOS 端末でも使えます。


## TODO

- [x] 輝度の取得
- [x] 正弦波の音を出す
- [x] 輝度と音を連動させる
- [x] 音量変更ボタンの有効化
- [x] カメラデバイス取得 (.devices()) の完全な Swift3 対応
- [ ] 音だけじゃなくて画面も変えたらいいかも？
- [ ] 幼児が好む色って...um
- [ ] 環境に合わせたキャリブレーション
- [x] 環境光に合わせて 25 音階
- [ ] ノイズをどうにかする

[Old Demo MP4 file (2.2MB).](./IMG_0043.mp4)


## License

The MIT License (MIT)
Copyright (c) 2016 tkumata

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
