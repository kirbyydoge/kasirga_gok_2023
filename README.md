# Teknofest Cip Tasarim 2023 - Kasirga Gök İslemcisi
<img src="https://user-images.githubusercontent.com/51290082/210544777-48d96615-e699-44f7-b176-6b13b69988f2.png" width="550" alt="boru_hattı" >
İşlemci boru hattı 7 aşamadan oluşmaktadır.

# Kasırga Gök

<img src="https://github.com/kirbyydoge/kasirga_gok_2023/assets/60625692/6d12445b-4319-4c51-8e26-c14a26b9f5f9" width="550">

## Takım Üyeleri
```
Prof. Dr. Oğuz Ergin - Danışman
Oğuzhan Canpolat     - Takım Kaptanı
Şevval İzmirli       - Yüksek Lisans Üye
Kerem Yalçınkaya     - Lisans Üye
```

## GitHub Yapısı

```
hdl/                        İşlemci gerçeklemesi ve doğrulaması donanım kaynakları
 |_ ip/                     Kullanılan Clock Wizard Vivado IP dosyaları (Vivado 2020.2) 
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
[Google Drive](https://drive.google.com/file/d/1BAunV44_JXPuDZf73AfrFf0elB2RZZjR/view?usp=share_link)

Text Link: https://drive.google.com/file/d/1BAunV44_JXPuDZf73AfrFf0elB2RZZjR/view?usp=share_link
