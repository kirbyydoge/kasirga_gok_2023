# OpenLane Akışı

İşlemci ana sayfada verildiği üzere OpenLane akışından başarılı bir şekilde geçmektedir. İşlemciyi akıştan geçirmek için aşağıdaki adımları izleyebilirsiniz:\
1 - `hdl/header` ile `hdl/src` klasörleri ve tüm alt klasörlerindeki .v ve .vh uzantılı dosyaları `openlane/src` klasöründe toplayın.\
2 - `sabitler.vh` dosyasından tüm FPGA kartı ile hata ayıklama tanımlamalarını kapatın ve `OPENLANE` ile `USE_MUL_PIPE` tanımlarını bırakın.\
3 - `L1B/V_SATIR` parametrelerini 128, `L1B_YOL` parametresini 6 ya da daha küçük ve `L1V_YOL` parametresini 2 olacak şekilde düzenleyin.\
4 - `openlane/runs` boş klasörünü oluşturun.\
5 - Bu klasör içeriğini OpenLane tasarım klasörleri arasına dilediğiniz isimle yerleştirin. (örn., `kasirgagok/<gds, lef, ....>`)\
6 - OpenLane ortamınızı aktif ederek `./flow.tcl -design kasirgagok -tag final -overwrite` komutu ile akışı başlatabilirsiniz.
