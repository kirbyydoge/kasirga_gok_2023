# İşlemci Parametreleri

Kasırga Gök işlemcisi parametreleri ile yüksek esneklik sunar. Aşağıdaki parametreleri kullanarak işlemcinin yapısını ve başarımını değiştirebilirsiniz.

## Önbellek Parametreleri

`L1_BLOK_BIT`: Sistemin ve ilk düzey önbelleklerin veri öbeği boyutunu belirtir. 32'nin tam katı olmalıdır.\
(ADRES_BYTE_BIT log2(\`L1_BLOK_BIT) olmalıdır)\
`L1B/V_SATIR`: Önbelleklerin satır sayılarını belirtir. Buyruk ve Veri önbelleği eşit satır sayısına sahip olmalıdır.\
(ADRES_SATIR_BIT log2(\`L1B/V_SATIR) olmalıdır)\
`L1B/V_YOL`: Önbelleklerin yol sayılarını belirtir. L1B ve L1V için farklı yol sayıları kullanılabilir. Kullanılan yollar herhangi bir tamsayı olabilir. (Openlane akışı için yalnızca 6/2 oranında SRAM'ler sunulmuştur.)

## SPI Parametreleri

`SPI_SEAMLESS`: Tanımlandığında ardışık komutlar takip ederek (cmd içerisinde belirtilmese bile) SCK gecikmelerini engeller.\
`SPI_IS_MSB`: 1 iken MSB, 0 iken LSB transfer yapar. Transferler her zaman little endian yapılır.

## Bellek Parametreleri

`BELLEK_BASLANGIC`: Ana bellek başlangıç adresini düzenler.\
`BELLEK_BOYUT`: Ana bellek boyutu. (Aşağıdaki harita parametre maskesi tarafından üstüne yazılır)

## Sistem Adres Haritası

`UART/SPI/RAM/TIMER/PWM_BASE_ADDR`: İlgili birimin başlangıç adresini tanımlar.\
`UART/SPI/RAM/TIMER/PWM_MASK_ADDR`: İlgili birimin erişim maskesini tanımlar.

# İşlemci Verilog Hiyerarşisi

```
teknofest_wrapper                     <teknofest_wrapper.v>
|_ soc                                <islemci.v>
  |_ cekirdek                         <cekirdek.v>
    |_ getir1                         <getir1.v>
    |_ getir2                         <getir2.v>
      |_ do                           <dallanma_ongorucu.v>
    |_ coz                            <coz.v>
    |_ yo                             <yazmac_oku.v>
      |_ rf                           <yazmac_obegi.v>
    |_ yurut                          <yurut.v>
      |_ amb                          <amb.v>
        |_ topla                      <toplayici.v>
        |_ carp                       <carpici[_pipe3].v>
        |_ bol                        <bolucu.v>
      |_ db                           <dallanma_birimi.v>
        |_ topla                      <toplayici.v>
      |_ yzb                          <yapay_zeka_birimi.v>
        |_ carp                       <carpici[_pipe3].v>
        |_ topla                      <toplayici.v>
    |_ bellek                         <bellek.v>
      |_ bib                          <bellek_islem_birimi.v>
      |_ vyb                          <veri_yolu_birimi.v>
    |_ gy                             <geri_yaz.v>
    |_ ddb                            <denetim_durum_birimi.v>
  |_ l1bd                             <l1b_denetleyici.v>
  |_ l1vd                             <l1v_denetleyici.v>
  |_ vyd                              <veri_yolu_denetleyici.v>
  |_ spid                             <spi_denetleyici.v>
    |_ spi                            <spi_birimi.v>
    |_ fifo_miso                      <fifo.v>
    |_ fifo_mosi                      <fifo.v>
    |_ fifo_cmd                       <fifo.v>
  |_ uartd                            <islemci.v>
    |_ rx_buffer                      <fifo.v>
    |_ tx_buffer                      <fifo.v>
    |_ alici                          <uart_alici.v>
    |_ verici                         <uart_verici.v>
  |_ pwmd                             <islemci.v>
    |_ p_w_m                          <pwm.v>
  |_ genblk1[0->L1BYOL].l1b_etiket    <islemci.v>
  |_ genblk1[0->L1BYOL].l1b_veri      <islemci.v>
  |_ genblk2[0->L1V_YOL].l1v_etiket   <islemci.v>
  |_ genblk2[0->L1V_YOL].l1v_veri     <islemci.v>
  !! #define OPENLANE !!
  |_ sram_336x128                     <sram_336x128.v> 
  |_ sram_112x128                     <sram_112x128.v>
|_ main_memory                        <teknofest_ram.v>
  |_ simpleuart                       <simpleuart.v>
  
```
