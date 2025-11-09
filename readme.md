# Second Chart Timeframe

![Version](https://img.shields.io/badge/version-1.04-blue)
![MT5](https://img.shields.io/badge/MT5-compatible-orange)

Indikator MetaTrader 5 untuk **candlestick berbasis detik** (1-59 detik). Cocok untuk scalping dan trading frekuensi tinggi.

<img width="1200" height="800" alt="BTCUSDM1" src="https://github.com/user-attachments/assets/db0c0702-d513-4029-a2b1-d1d133bc57dc" />

## Fitur

- Periode detik yang dapat disesuaikan (1-59 detik)
- Update OHLC real-time
- Timer countdown visual
- Tampilan di window terpisah

## Instalasi

1. Copy `SecondTimeframeIndicator.mq5` ke folder `MQL5/Indicators/`
2. Compile di MetaEditor
3. Restart MT5
4. Drag ke chart

## Parameter

| Parameter | Default | Deskripsi |
|-----------|---------|-----------|
| InpSecondPeriod | 5 | Periode dalam detik (1-59) |
| InpCandleColor | DodgerBlue | Warna candle |
| InpCandleWidth | 1 | Lebar garis |
| InpMaxBars | 200 | Maksimal history |
| InpShowInfo | true | Tampilkan info panel |


## Kebutuhan Sistem

- MetaTrader 5 Build 3802+
- Market aktif dengan data tick

## Troubleshooting

**Candle tidak muncul?** Pastikan market aktif dan indikator ada di window terpisah.

**Masalah performa?** Kurangi `InpMaxBars` jadi 50-100.

**Timer tidak jalan?** Restart indikator atau MT5.

## Disclaimer

**Hanya untuk tujuan edukasi.** Trading melibatkan risiko. Test di demo terlebih dahulu. Bukan saran finansial.

---

🐛 [Laporkan Issue](https://github.com/msyamsudin/MetaTrader-5-Indicator-Second-Timeframe/issues)
