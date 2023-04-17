# Teknofest Cip Tasarim 2023 - Kasirga Gök İslemcisi
<img width="505" alt="boru_hattı" src="https://user-images.githubusercontent.com/51290082/210544777-48d96615-e699-44f7-b176-6b13b69988f2.png">
İşlemci boru hattı 7 aşamadan oluşmaktadır.

## GitHub Yapısı

```
hdl/                        İşlemci gerçeklemesi ve doğrulaması donanım kaynakları
 |_ constraints/            VCU108 ve Nexys için XDC dosyaları
 |_ header/                 Verilog header dosyaları
 |_ sim/                    Verilog simülasyon dosyaları
   |_ model/                Simülasyon ve FPGA ortamı için bellek modelleri
 |_ src/                    İşlemci kaynak kodu
   |_ bellek_hiyerarsisi/   Önbellekler, Ana bellek denetleyicisi ve bellek işlem birimleri
   |_ cevre_birimleri/      UART, SPI ve PWM birimleri ile denetleyicileri
   |_ README.md             !! İşlemci hiyerarşisi !!
kaynaklar/                  İşlemci test ve doğrulaması için kullanılan harici dosyalar
 |_ spike_debug/            SPIKE simülatörü ile debug kaynakları
 |_ compile/                RISC-V Baremetal ortamı taban derleyicisi
 |_ coremark/               Kasırga Gök işlemcisine uygun CoreMark gerçeklemesi
 |_ dhrystone/              Kasırga Gök işlemcisine uygun Dhrystone gerçeklemesi
 |_ mem_test/               Önbellek ve Ana bellek stres testleri
 |_ rv32test/               Resmi RISC-V Toolchain testleri
   |_ rv32imc-dump/           -> Assembly
   |_ rv32imc-elf/            -> Binary
   |_ rv32imc-hex/            -> Hex
   |_ elf2hex.sh            Elf dosyalarını hex dosyasına dönüştüren script
 |_ uart_test/              UART alıcı ve verici testleri
 |_ README.md               !! Koşulan testler ve baremetal ortamı hakkında bilgiler !!
openlane/                   Kullanılan SRAM kütüphaneleri ve OpenLane konfigürasyonu
 |_ README.md               !! OpenLane koşulmadan önce yapılması gerekenler !!
```

## OpenLane Sonuç Bağlantısı

