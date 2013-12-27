# SPARC64(TM) VIIIfx/IXfx 精密プロファイラ解析スクリプト

## 概要

Fujitsu PRIMEHPC FX10や京コンピュータにおける、精密プロファイラの出力するcsvファイルを解析し、結果を標準出力に出力するスクリプト。

- rprof.rb 解析スクリプト
- events.csv イベントテーブル

## 使い方

イベントテーブルファイル(events.csv)及び解析スクリプトrprof.rbと同じところにcsvファイルを用意し、以下のように利用します。

  $ ruby rprof.rb output_prof*.csv

出力結果は、プロセス及びスレッド単位。観測範囲(start/end_collectionで挟まれた場所)は全てまとめて出力します。シングルスレッドジョブ、flat-MPI、hybridに対応しているはずで、FX10/京も自動判別するはずですが動作については保証しません。

## 注意事項

- 精密プロファイラの利用方法が誤っていると正しく情報を取得できません。精密プロファイラの使い方や、ジョブの投入方法については、各サイトのマニュアルを参照してください。スクリプト作者への問い合わせはご遠慮ください。
- 本スクリプトの出力結果の正確さについては保証しません。バグの報告は歓迎いたしますが、サポートの保証はしません。
- 本スクリプトについて富士通株式会社や理化学研究所は無関係です。本スクリプトについて富士通株式会社や理化学研究所への問い合わせはご遠慮ください。
- 本スクリプトは、精密プロファイラの仕様変更によって使えなくなる可能性があります。

## ライセンス

本スクリプトは修正BSDライセンス(二条項BSDライセンス)にて提供いたします。

## 出力内容の説明

### Performance Information
全体的な性能を表示するセクション。

- ELAPSED 経過時間。単位は秒。
- MFLOPS 演算性能。単位はMFLOPS。
- PEAK(%) ピーク性能比。
- MIPS 演算数。単位はMIPS(百万インストラクション毎秒)

### SIMD Information
浮動小数点演算と、そのSIMDの性能を表示するセクション。

- SIMD(%)SIMD化された浮動小数点演算(乗算/加減算)の割合。
- FLOAT(%) SIMD化されていない浮動小数点演算(乗算/加減算)の割合。
- SIMD-FMA(%) SIMD化された積和演算の割合。
- FMA(%) SIMD化されていない積和演算の割合。

### Cache Information
キャッシュミス関連

- L1DMISS(%) L1データキャッシュミス率
- L2MISS(%) L2キャッシュミス率
- MTLBMISS(%) データメインTLBミス率
- UTLBMISS(%) マイクロデータTLBミス率

### Wait Information (Instruction)
待ち情報(命令関連)

- BARRIER(%) スレッド同期待ち割合(MPIのバリアではない)
- INTWAIT(%) 整数演算の依存関係による待ち割合
- FLWAIT(%) 浮動小数点演算の依存関係による待ち割合
- BRWAIT(%) 分岐命令による待ち割合
- INSTFETCH(%) 命令フェッチ待ち割合

### Wait Information (Memory/Cache)
待ち情報(メモリ/キャッシュ関連)

- IMEMWAIT(%) 整数のメモリからのロード待ち
- ICACHEWAIT(%) 整数のキャッシュからのロード待ち
- FLMEMWAIT(%) 実数のメモリからのロード待ち
- FLCACHEWAIT(%) 実数のキャッシュからのロード待ち

### Commit Information 
命令コミット情報

- 0ENDOP(%) 命令を一つも発行しなかったサイクル割合
- 1ENDOP(%) 1サイクルで一つ命令を発行した割合
- 2/3ENDOP(%) 1サイクルで二つないし三つの命令を同時に発行した割合
- GPRWAIT(%) GPR書き込みポートが埋まっているため4命令同時発行できなかった割合 (整数レジスタを2つアップデート中)
- 4ENDOP(%) 1サイクルで4つの命令を同時に発行した割合


### Other Information 
その他

- IPC サイクルあたりの平均命令数(Instruction Per Cycle)

###Measured Events
取得したイベントリスト。詳細については[SPARC64(TM) VIIIfx Extensions (PDF)](http://img.jp.fujitsu.com/downloads/jp/jhpc/sparc64viiifx-extensionsj.pdf)を参照すること。
