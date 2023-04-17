# Derleyici

`compile/` klasörü Makine Modu destekleyen RISC-V işlemciler için Baremetal ortamı ve basit testleri içerir. Bu derleyici yalnızca tek kaynak kodundan oluşan testler için tasarlanmıştır.

## Örnek Kullanım

`make <program>`

## kasirga.h

UART durum yazmaçlarının kontrol edilmesi, string yardımcı ile printf fonksiyonlarını barındırır. Makine modunda oluşan traplere müdahale etmek için `void handle_trap` metodunu değiştirebilirsiniz.

## Mevcut Özel Testler

`looptest`: Boru hattında dallanmaların test edilmesi için döngü.\
`fotobas`: ASCII sanatı ile oluşturulan fotoğrafları basar. (kasirga.h kütüphanesi printlerini kullanarak kendi fotoğrafınızı yüklemelisiniz)\
`memtest`: Önbellek ve ana bellek için stres testleri.\
`multest`: Vektör dot product testi.

## RV32-Test

[Resmi RISC-V Testleri](https://github.com/riscv-software-src/riscv-tests) rv32-imc eklentisi için testlerini içerir. Testleri yüklemek için `rv32imc-hex` klasöründeki dosyaları kullanabilirsiniz.

## Dhrystone

[Dhrystone Testi](https://en.wikipedia.org/wiki/Dhrystone) ve testlerle uyumlu Kasırga Gök Baremetal ortamı gerçeklemesini içerir. Derleyici değişiklikleri gerektirdiğinden `compile` klasöründeki derleyici dosyalarının ortam uyumlu versiyonlarını içerir.

`kasirga.h`: `CPU_HZ` ve `BAUD_RATE` sırası ile işlemci frekansı ve UART baud rate belirtmelidir.
`dhrystone.c`: `LOOPS` çalıştırılacak Dhrystone iterasyonlarını belirtir.

Kasırga Gök işlemcisi 100MHz ile VCU108 kartında 166,666 dhrystone/saniye skora sahiptir.

Derlemek için: `make -B dhrystone`

## CoreMark

[CoreMark Testi](https://github.com/eembc/coremark) ve testlerle uyumlu Kasırga Gök Baremetal ortamı gerçeklemesini içerir. Derleyici değişiklikleri gerektirdiğinden `compile` klasöründeki derleyici dosyalarının ortam uyumlu versiyonlarını içerir.

`kasirga.h`: `CPU_HZ` ve `BAUD_RATE` sırası ile işlemci frekansı ve UART baud rate belirtmelidir.
`core_portme.h`: `ITERATIONS` çalıştırılacak Dhrystone iterasyonlarını belirtir.

Kasırga Gök işlemcisi 100MHz (125MHz) ile VCU108 kartında 181 (226) CoreMark iterasyon/saniye skorune sahiptir.

Derlemek için: `make -B core_main`
