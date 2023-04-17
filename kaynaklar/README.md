# Derleyici

`compile/` klasörü Makine Modu destekleyen RISC-V işlemciler için Baremetal ortamı ve basit testleri içerir. Bu derleyici yalnızca tek kaynak kodundan oluşan testler için tasarlanmıştır.

## Örnek Kullanım

`make <program>`

## kasirga.h

UART durum yazmaçlarının kontrol edilmesi, string yardımcı ile printf fonksiyonlarını barındırır. Makine modunda oluşan traplere müdahale etmek için `void handle_trap` metodunu değiştirebilirsiniz.

# Testler

`looptest`: Boru hattında dallanmaların test edilmesi için döngü.\
`fotobas`: ASCII sanatı ile oluşturulan fotoğrafları basar. (kasirga.h kütüphanesi printlerini kullanarak kendi fotoğrafınızı yüklemelisiniz)\
`memtest`: Önbellek ve ana bellek için stres testleri.\
`multest`: Vektör dot product testi.

## RV32-Test

[Resmi RISC-V Testleri](https://github.com/riscv-software-src/riscv-tests) rv32-imc eklentisi için testlerini içerir. Testleri yüklemek için `rv32imc-hex` klasöründeki dosyaları kullanabilirsiniz.

## Dhrystone

[Dhrystone Testi](https://en.wikipedia.org/wiki/Dhrystone) ve testlerle uyumlu Kasırga Gök Baremetal ortamı gerçeklemesini içerir. Derleyici değişiklikleri gerektirdiğinden `compile` klasöründeki derleyici dosyalarının ortam uyumlu versiyonlarını içerir.

`kasirga.h`: `CPU_HZ` ve `BAUD_RATE` sırası ile işlemci frekansı ve UART baud rate belirtmelidir.\
`dhrystone.c`: `LOOPS` çalıştırılacak Dhrystone iterasyon sayısını belirtir.

Kasırga Gök işlemcisi 100MHz ile VCU108 kartında 166,666 dhrystone/saniye skora sahiptir.

Derlemek için: `make -B dhrystone`

## CoreMark

[CoreMark Testi](https://github.com/eembc/coremark) ve testlerle uyumlu Kasırga Gök Baremetal ortamı gerçeklemesini içerir. Derleyici değişiklikleri gerektirdiğinden `compile` klasöründeki derleyici dosyalarının ortam uyumlu versiyonlarını içerir.

`kasirga.h`: `CPU_HZ` ve `BAUD_RATE` sırası ile işlemci frekansı ve UART baud rate belirtmelidir.\
`core_portme.h`: `ITERATIONS` çalıştırılacak CoreMark iterasyon sayısını belirtir.

Kasırga Gök işlemcisi 100MHz (125MHz) ile VCU108 kartında 181 (225) CoreMark iterasyon/saniye skora sahiptir.

Derlemek için: `make -B core_main`

# Spike Debug

İşlemcide karşılaşılan hataların hızlıca tespit edilebilmesi için [Spike](https://github.com/riscv-software-src/riscv-isa-sim) simülatöründen faydalanılmıştır. Tasarlanan scriptler ile derlenen kodlar Spike ve Vivado simulasyonunda yürütülür ve buyruklar geri yaz ile bellek aşamalarında incelenerek hem program akış sırası hem de mimari durum güncellemeleri takip edilir.

Bu özelliğin kullanılabilmesi için Spike `--enable-commiblog` kullanılarak derlenmelidir. Programınızı kıyaslamak için spike_debug klasörinde aşağıdaki adımları izleyin:\
1 - `spike --isa=rv32imc --pc=0x40000000 -m0x40000000:0x400000,0x20000000:0x1000,0x30000000:0x1000 --log-commits <program> 2> golden.txt` komutunu kullanın ve programınızı çalıştırın. Dilerseniz program bir süre çalıştırdıktan sonra Ctrl+C ile akışı erken sonlandırabilirsiniz.\
2 - `/hdl/header/sabitler.vh` içerisinden `SPIKE_DIFF` tanımını aktif edin.\
3 - `/hdl/sim/tb_teknofest_wrapper.v` testbenchinden RISCV_TEST, STANDALONE_PATH, LOG_PATH VE UART_PATH parametrelerini sırasıyla `0`, `<program>`, `/kaynaklar/spike_debug/vivado.txt` ve `/kaynaklar/spike_debug/uart.txt` olacak şekilde güncelleyin.\
4 - Testbench üzerinden dilediğiniz miktarda programınızı ilerletin.\
5 - Bu adımlar tamamlandıktan sonra, `spike_debug` klasöründeki `compare.sh` scriptini çalıştırarak oluşan farkları `diff.txt` dosyasında görüntüleyebilirsiniz.
