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
