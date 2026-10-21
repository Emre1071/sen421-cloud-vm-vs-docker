# HAFIZA.md — SEN421 Topic 2 proje hafızası

> Oturum başlangıcında **önce bu dosya** okunur; kod taramasıyla yeniden keşfedilmesi gereken kararlar burada durur.
>
> **Yetki sırası:**
> 1. `../information_pdf/SEN421_Cloud_Project_Guidelines_Fall2026.pdf` (26 Eylül 2026, Dr. Hazm Talab) — ödev kuralı
> 2. `../information_pdf/SEN421_Fall2026_Sample_Report_Template.tex` — IEEE konferans iskeleti
> 3. `HAFIZA.md` — bu dosya: özet, durum, yön
>
> Çelişki varsa üstteki dosya kazanır. Bu dosya kural koymaz; PDF ve TeX ile çelişen bir satır burada kalsa da onlar geçerlidir. Şablon 1.0'daki `docs/CLAUDE.md`, `docs/PLAN.md` ve `design-kit/DESIGN-SYSTEM.md` bu derste yok ve açılmayacak.
>
> `../` altındaki dosyalar salt okunurdur. Yazma ve silme yalnız `Project/` içindedir.
>
> Son güncelleme: 2026-10-21 (`paper/report.pdf` 5 sayfa derlendi; `.gitignore` ve `README.md` yazıldı; slayt 8 sayfa ve sayı tablolu).

## 0. İşaret sözlüğü

| İşaret | Anlamı |
|---|---|
| ✅ | bitti ve doğrulandı |
| 🔄 | devam ediyor |
| ⏭️ | açık kalan iş (karar değil) |
| 🔶 | commit'lenmemiş / yayınlanmamış çalışma |
| 🔴 | kritik uyarı, yanlış bilgi düzeltmesi |
| ⚠️ | tuzak, kolay gözden kaçan ayrıntı |
| ℹ️ | bağlam notu |
| 🔒 | izinsiz yapılmayacak iş |

🔴 Hafızanın "açık" dediği bir karar verilmişse iş atlanır. Her oturum sonunda §15 ritüeli uygulanır. Ölü satır silinir; bu dosya arşiv değildir.

## 1. Proje kimliği

- **SEN421 Cloud Architecture and Services Course Project (Fall 2026), Topic 2 — Virtual Machines vs. Containers (Part A: Hands-on Deployment).** Vaadi: aynı web API'yi Type-2 hipervizör üzerindeki Ubuntu VM ile paylaşılan çekirdekli Docker konteynerinde çalıştırıp açılış, gecikme, verim, bellek ve disk boyutunu ölçmek; AWS fiyat projeksiyonu ile yalıtım ve KVKK bedelini aynı soruya bağlamak.
- Ders: İstanbul Aydın Üniversitesi, Bilgisayar Mühendisliği, SEN421. Değerlendiren: Dr. Hazm Talab. Ağırlık: final notunun 20 puanı. Tür: bireysel. Sunumsuz teslim 0 puan alır.
- Hedef kitle: dersi veren öğretim elemanı ve sınıf. Arayüz dili: rapor ve slayt İngilizce; bu hafıza Türkçe. Uygulama JSON döner, kullanıcı arayüzü yoktur.
- Karar mercii: öğrenci (kimlik bilgisi bu dosyada yok). Kapsam kilitleri aşağıda mimari karar olarak durur; öğrenci bunları değiştirirse gerekçe bu bölüme yazılır.
- **Kilitli başlık:** Performance, Resource Utilization, and Cost Analysis of Web Applications: Virtual Machines vs. Docker Containers
- **Kilitli soru:** How much faster does a containerized web API start and respond compared to a virtual machine under identical load, and what are the trade-offs in resource overhead and isolation?
- **Çekirdek döngü:** aynı API'yi iki hedefe kur → tek tek soğuk aç → aynı k6 yükünü uygula → üç koşunun ortalama ve örneklem standart sapmasını yaz → AWS Pricing Calculator ile aylık bedeli çıkar → yalıtım ve KVKK farkını tartış.
- **Ayrışma:** Topic 2 örneği yalnız açılış hızını ve autoscaling'e etkisini sorar. Bu proje autoscaling sormaz. Soruya yanıt süresi, kaynak yükü ve yalıtım eklenmiştir. Karşılaştırma yereldir; AWS hesabında kaynak açılmaz, bedel projeksiyondur.
- Teslim: IEEE konferans PDF (hedef 6–8 sayfa, üst sınır 10; sınır özet, şekil, tablo, AI beyanı, kaynakça ve eki kapsar), 6–10 slaytlık sunum PDF'i, GitHub'da kod. Konuşma 5–8 dakika, soru en çok 2 dakika, 10. dakikada kesilir. Geç teslim günde %20, 5 günden sonra kabul yok. Teslim günü PDF'te yazılı değildir.
- ℹ️ Öğrenci adı, numarası ve `stu.aydin.edu.tr` adresi §7'de açıktır. Uydurulmaz.

## 2. Depo haritası

| Klasör | İçerik |
|---|---|
| `HAFIZA.md` | Bu dosya. Karar ve gerekçe. Kod kopyalanmaz. |
| `app/` | Karşılaştırılan REST API. Aynı ağaç VM imajına ve Docker imajına girer. |
| `load-tests/` | k6 betiği, üç koşuluk koşucu, ortalama ve standart sapma hesabı, `results/` çıktıları. |
| `vm-setup/` | Ubuntu misafir kurulum betiği ve systemd birimi. Sanal disk imajı repoda durmaz. |
| `paper/` | IEEE LaTeX, draw.io mimari şeması, sonuç şekilleri, sunum PDF'i. |

ℹ️ `.scratch/`, `design-kit/` ve ayrı bir `docs/` otoritesi yok. Faz durumu §7'dedir. `../information_pdf/` ve `../Hafıza.txt` referanstır, kaynak kod değildir, değiştirilmez.

## 3. Ölçüm mimarisi

Ürün istemcisi, tasarım token'ı, zarf şeması ve mock API katmanı bu projede yoktur; şablondaki o bölümler silindi. Sistem altında test edilen şey uygulama zekâsı değil, iki çalıştırma modelidir.

### Katmanlar

```
Project/
├── app/
│   ├── main.py                → FastAPI; /health ve /payload gövdeleri içe aktarımda bir kez kurulur
│   ├── requirements.txt       → fastapi==0.156.1 ve uvicorn==0.54.0
│   ├── Dockerfile             → python:3.12-slim, iki aşama, aynı main.py
│   └── docker-compose.yml     → 2 vCPU, 2 GB, takas tavanı belleğe eşit
├── vm-setup/
│   ├── Vagrantfile            → bento/ubuntu-24.04, 2 vCPU, 2048 MiB, konak 127.0.0.1:8000
│   ├── provision.sh           → python3 venv, aynı uvicorn komutu, systemd `webapi.service`
│   └── setup-vm.ps1           → `vagrant up --provider virtualbox`
├── load-tests/
│   ├── test-script.js         → 50 VU, 30 sn, /compute ve /payload
│   ├── run_benchmarks.ps1     → 3 koşu, arada 15 sn, results/docker/
│   └── results/               → koşu JSON'u: ortalama, medyan, p95, req/s
└── paper/
    ├── main.tex               → örnek TeX iskeletinin doldurulmuş hali
    ├── refs.bib               → IEEE kaynaklar (okunmuş kaynaklar)
    ├── figures/architecture.drawio
    └── slides.pdf
```

Bağımlılık yönü: `load-tests` yalnız HTTP uçlarını bilir; `app` test koşucusunu tanımaz; `paper` rakamları `load-tests/results/` ve hesap makinesi çıktısından alır, uydurmaz.

### Karşılaştırılan alternatifler

İki alternatif vardır. Üçüncü bir çalışma modeli (Kubernetes, PaaS, FaaS, autoscaling) kapsam dışıdır.

| | A — Sanal makine | B — Konteyner |
|---|---|---|
| Yerleşim | Type-2 hipervizör, VirtualBox | Docker Engine, paylaşılan konak çekirdeği |
| Konak | Ölçüm anında Ubuntu | Aynı Ubuntu konak |
| Misafir / imaj | Ubuntu 24.04 LTS | `python:3.12-slim` |
| CPU tavanı | 2 vCPU | `--cpus=2.0` |
| Bellek tavanı | 2048 MiB, takas yok | `mem_limit` 2g ve `memswap_limit` 2g |
| Süreç modeli | systemd → uvicorn, 2 worker, `0.0.0.0:8000` | aynı uvicorn komutu |
| Yayın | NAT, yalnız `127.0.0.1:8000` | `127.0.0.1:8000:8000`, imaj `sen421-api:latest` |
| Neden bu tavan | AWS `t3.micro` 2 vCPU ve 1 GiB. Yerel tavan, fiyat satırındaki şekle yaklaşsın diye kilitlendi. | Aynı tavan. Konteynerin konağın bütün RAM'ine taşması kıyası bozar. |

Neden VirtualBox: yönergedeki yerel hipervizör listesinde ilk sırada, ücretsiz, Type-2. Neden KVM değil: Windows geliştirme makinesinden Ubuntu ölçüm konağına geçişte VirtualBox her iki tarafta da aynı ürün. Neden FastAPI + uvicorn: 2026-10-20 öğrenci kararı; ders şablonundaki Flask örneği bu yüzden uygulanmadı. `uvicorn[standard]` yazılmaz; uvloop ve httptools iki tarafta da yoktur. Worker sayısı 2, çünkü tavan 2 vCPU. Neden veritabanı yok: ikinci bir hizmet, VM ile konteyner farkını örter.

🔴 Düzeltme (2026-10-20): ilk hafızadaki 1024 MiB ve Flask/gunicorn kilidi yürürlükten kalktı. Yerel tavan artık 2 vCPU ve 2048 MiB'dir. `t3.micro` hâlâ 1 GiB'dir; projeksiyon satırı değiştirilmedi. Bu şekil farkı raporda sınır olarak yazılır.

🔴 **Windows üzerinde Docker Desktop ile ölçüm yapılmaz.** Docker Desktop, konteynerleri WSL2 yardımcı sanal makinesinin içinde çalıştırır. O düzenek "paylaşılan konak çekirdeği" iddiasını bozar: iki taraf da bir hipervizörün arkasında kalır ve soru yanlış cevaplanır. Kod Windows'ta yazılabilir. Ölçüm konağı, VirtualBox ile Docker Engine'in aynı çekirdek üzerinde yan yana durduğu Ubuntu'dur. Konak çekirdek sürümü ölçüm günü `uname -r` ile kayda geçer; burada tahmin edilmez.

⚠️ `t3.micro` patlamalı CPU kredisi yerel işlemcide yoktur. Rapor bunu sınır olarak yazar. Yerel sonuç, bulut gecikmesinin kendisi diye sunulmaz.

⚠️ İstemci her iki koşuda da ölçüm konağındaki k6'dır. VM yolu NAT, konteyner yolu veth/bridge'dir. Bu fark düzeltilip yok edilmez; platform yolunun parçasıdır ve metodolojide adı konur.

### Uygulama sözleşmesi

Sentetik veri. Kişisel veri, hesap, oturum ve veri tabanı yoktur. Yük her istekte aynı bayt dizisidir; gecikme saçılımı gövde üretiminden gelmesin diye JSON süreç açılışında bir kez serileştirilir.

| Yöntem ve yol | Gövde | Ölçümdeki yeri |
|---|---|---|
| `GET /health` | `{ "status": "ok" }` | Soğuk açılış yoklaması. Gövde içe aktarımda sabittir. |
| `GET /compute` | 50000 SHA-256 turu ve özet | CPU senaryosu. Her istekte yeniden hesaplanır; önbellek yok. |
| `GET /payload` | Tam 65536 bayt JSON | Bant genişliği senaryosu. Gövde içe aktarımda bir kez kurulur. |

Ürün zarfı (`success`, `errorCode`) kullanılmaz. OpenAPI uçları kapalıdır. Üç uç ölçülür; ölçülmeyen dördüncü uç eklenmez.

k6 kilidi 2026-10-20 öğrenci kararıyla değişti: 50 VU, 30 saniye, aynı pencerede sırayla `/compute` ve `/payload`. Eşik: HTTP 200 oranı > %99 ve p95 < 500 ms. Üç koşu, arada 15 saniye boşta bekleme. Rapor süresi 30 saniyedir, 10 dakika diye yazılmaz.

Kabul koşulu: k6 çıkış kodu 0. Eşik düşerse JSON yine yazılır ama o tur ortalamaya karışmaz; üçlü set yeniden alınır. Geçerli ama kötü görünen koşu atılmaz.

### Ölçüm protokolü

Her tekrar `r = 1, 2, 3` için sıra VM, sonra konteynerdir. İkisi aynı anda ayakta değildir. k6 koşuları arası bekleme 15 saniyedir (`run_benchmarks.ps1`). Platform değişmeden önce konak 120 saniye boşta bekler.

Bir platform adımının saati:

1. Hedef kapalıyken saat başlar. VM için başlangıç `VBoxManage startvm` anıdır (kayıtlı durum yok, soğuk açılış). Konteyner için başlangıç `docker run` anıdır. İmaj daha önce çekilmiştir; çekme süresi açılışa yazılmaz.
2. Konaktan `http://127.0.0.1:8000/health` 200 dönene kadar geçen süre saniye cinsinden soğuk açılıştır. SSH süresi ölçüme dahil edilmez.
3. 60 saniye boşta beklenir. Boşta bellek yazılır.
4. 30 saniye ısınma, atılır.
5. Sayılan k6 koşusu. Docker özeti `load-tests/results/docker/results_run{r}.json` dosyasına yazılır (`mean_ms`, `median_ms`, `p95_ms`, `req_per_s`). Yük altı bellek bu pencerede örneklenir.
6. Hedef kapatılır. 120 saniye beklenir.

| Metrik | Birim | VM kaynağı | Konteyner kaynağı | Kaç gözlem |
|---|---|---|---|---|
| İmaj / disk boyutu | MB ve GB | Konaktaki sanal disk dosyasının bayt boyu (`VBoxManage showhdinfo`) | `docker image inspect` → `Size` | 1 (deterministik). Standart sapma yok. |
| Soğuk açılış | s | Yukarıdaki saat | Yukarıdaki saat | 3 |
| Bellek, boşta | MiB | `VBoxHeadless` konak çalışma kümesi | `docker stats --no-stream` | 3 |
| Bellek, yük | MiB | Aynı araç, k6 penceresindeki tepe | Aynı araç, tepe | 3 |
| Verim | istek/s | k6 `http_reqs` hızı | aynı | 3 |
| Gecikme ortanca | ms | k6 `http_req_duration` medyan | aynı | 3 |
| Gecikme 95. yüzdelik | ms | k6 `http_req_duration` p(95) | aynı | 3 |

⚠️ Birincil bellek kıyası konağın gördüğü bayttır. Misafir içindeki `free` ile `docker stats` aynı şeyi ölçmez; misafir `MemAvailable` ancak ikincil satır olarak, ayrı etiketlenerek yazılır.

Üç geçerli gözlem `x1, x2, x3` için:

- ortalama = `(x1 + x2 + x3) / 3`
- örneklem standart sapma = `sqrt( ((x1-ortalama)^2 + (x2-ortalama)^2 + (x3-ortalama)^2) / 2 )`

Payda `n-1 = 2`'dir. Rapor `ortalama ± standart sapma` biçimini kullanır. Tek koşu rakamı tabloya girmez.

İkincil disk satırı, misafirde `df -B1 /` kullanılan alandır. Birincil "MB'a karşı GB" sütunu konak artefaktıdır: Docker imaj boyu ve sanal disk dosyası.

### Maliyet, sorumluluk ve KVKK

Yerel deneyde AWS kaynağı açılmaz. Deneyin gerçekleşen bedeli, kaynak açılmadıysa 0 USD'dir ve raporda "oluşturulmuş bulut kaynağı yok" diye doğrulanır. Aylık kıyas projeksiyondur.

🔒 Erişim tarihi, bölge ve fiyat listesi URL'si tablonun yanında durur. Serbest katman ana toplamın içine gizlenmez.

Kilitli hesap makinesi girdileri (rakam değil, girdi):

- Araç: AWS Pricing Calculator, `https://calculator.aws`
- Bölge: Europe (Frankfurt) `eu-central-1`. Türkiye'de AWS bölgesi yoktur; Frankfurt, KVKK yurt dışı aktarım tartışması için seçildi.
- Para birimi USD. Süre 730 saat/ay. Satın alma: On-Demand, paylaşılan tenancy, Linux. Reserved ve Spot kullanılmaz.
- İş yükü varsayımı: günde 100.000 istek, ayda 3.000.000 istek. Giden trafik satırı yalnız `/payload` gövdesidir: 65536 bayt × 3.000.000 = 196608000000 bayt = 196,608 GB. `/health` ve `/compute` bu satıra karışmaz.
- EC2: 1 adet `t3.micro`, 20 GB gp3 kök disk (2026-10-21 görev satırı; önceki 8 GB kilidi bu tablo için kapandı), elastik IP bırakılmaz, yük dengeleyici yok.
- ECS/Fargate, Linux/x86, tek görev, 730 saat, yük dengeleyici yok. 2026-10-21 tablo profili 0.25 vCPU ve 0.5 GB'dir. Fargate 2 vCPU + 1 GiB satmaz. Bu profil yerel 2 vCPU / 2 GB tavanına eşit değildir; raporda bu fark yazılır.
- Serbest katman ana toplamın içine gizlenmez. Kalıcı kıyas liste fiyatıdır.
- 2026-10-21 fiyat listesi, erişim aynı gün. EC2 Linux on-demand `t3.micro` 0.012 USD/saat (yürürlük 2026-10-01) × 730 = 8.76. gp3 `EUC1-EBS:VolumeUsage.gp3` 0.0952 USD/GB-ay × 20 = 1.904. Fargate vCPU 0.04656 USD/saat × 0.25 × 730 = 8.4972; bellek 0.00511 USD/GB-saat × 0.5 × 730 = 1.86515; işlem 10.36235. Ek ephemeral yok, depolama 0. Giden trafik EU (Frankfurt) → External, ilk 10 TB, 0.090 USD/GB (yürürlük 2026-06-01) × 196.608 = 17.69472. Toplam EC2 28.35872, Fargate 28.05707. 100 GB payı düşülmedi. Deney bedeli 0 USD.

Sorumluluk çerçevesi (rapor tablosunun iskeleti):

| Katman | Yerel VM | EC2 | Fargate |
|---|---|---|---|
| Fiziksel tesis, donanım | Öğrenci | AWS | AWS |
| Hipervizör / konak çekirdeği | Öğrenci | AWS | AWS |
| Misafir işletim sistemi yamaları | Öğrenci | Müşteri | AWS (konak); imajın içi müşteri |
| Uygulama, imaj içeriği, uvicorn | Öğrenci | Müşteri | Müşteri |
| Güvenlik grubu, IAM, ağ yayını | Öğrenci (loopback) | Müşteri | Müşteri |
| Veri | Sentetik; öğrencide | Müşteri | Müşteri |

Yalıtım gerekçesi, ölçüm ne çıkarsa çıksın raporda durur: VM ayrı çekirdek ve donanım sanallaştırması taşır, çekirdek hatası misafirde kalır, disk ve açılış büyüktür. Konteyner `pid`, `net`, `mnt`, `uts`, `ipc` ve `user` namespace'leri ile cgroup tavanı kullanır; çekirdek ortaktır, çekirdek açığı konteynerden konağa sıçrayabilir, imaj ve açılış küçüktür. Hız kazancı bu yalıtım bedeline karşı yazılır.

KVKK çerçevesi: deneyde kişisel veri yoktur ve buluta yüklenmez. Tartışma, bu API kişisel veri taşısaydı ne değişirdi sorusuna cevap verir. Veri sorumlusu müşteridir; AWS işleyen olur. `eu-central-1` Türkiye dışıdır, KVKK m.9 yurt dışı aktarım rejimi uygulanır. Yerel ölçüm makinesi veriyi ülkede tutar. Bu fark hız tablosundan bağımsız bir ödünleşimdir. Bu dosya hukuki mütalaa değildir.

### Bağımlılıklar

`app/requirements.txt`: fastapi==0.156.1, uvicorn==0.54.0 (PyPI, 2026-10-20). Python 3.12, Docker Engine, VirtualBox, k6, çizim için diagrams.net. İzleme yığını kurulmaz.

### Özellik kaydı kuralı

Bir dilim ancak ölçülünce ✅ olur. Kod bu dosyaya kopyalanmaz.

### app 🔄 (2026-10-20)

1. Boş `app/` → `main.py`, `requirements.txt`, `Dockerfile`, `docker-compose.yml`.
2. Öğrenci Flask/gunicorn ve 1024 MiB kilidini bu oturumda kaldırdı. Üç ölçüm ucu istedi.
3. ⚠️ `/payload` tam 65536 bayttır ve süreç açılışında kurulur. `/compute` her istekte 50000 tur döner; özet saklanırsa CPU ölçümü yalan olur.
4. OpenAPI, veritabanı ve `uvicorn[standard]` yazılmadı.
5. Doğrulama: 2026-10-20 yerel içe aktarma. `/payload` 65536 bayt ve geçerli JSON; `/compute` 50000 tur ve 64 karakterlik özet döndürdü. İmaj kurulmadı, HTTP ile koşulmadı.

## 4. Test düzeni

- Performans kanıtı birim test değildir. Kanıt, §3 protokolünden çıkan üç JSON ve `aggregate.py` çıktısıdır.
- `aggregate.py` saf hesap yapar: üç sayı girer, ortalama ve `n-1` sapma çıkar. El ile hesaplanmış tablo rapora yapışmaz.
- ℹ️ 2026-10-20: Docker k6 JSON sayısı 3. Run 3 p95 eşiğini aştı; kabul edilmiş üçlü henüz yok. VM JSON sayısı 0.
- Zincir: `main.py` → `/compute` ve `/payload` → `test-script.js` → `results/docker/results_runN.json`. `aggregate.py` henüz yok.
- ⚠️ Windows'ta betik yazılırken yol ayracı ve UTF-8 sabittir. Ölçüm betiği Ubuntu bash ile koşar. k6 özeti İngilizce sayı biçimindedir (ondalık nokta).
- 🔴 Rakam, ekran görüntüsü veya fiyat uydurulmaz. Beklenmeyen sonuç silinmez; Discussion'da açıklanır.

### Otomatik denetim

Lint yerine teslim denetimi vardır. Rapor PDF'i basılmadan önce §6'daki 13 maddelik liste elle işaretlenir. IEEE kenar boşluğu, punto ve satır aralığı değiştirilerek sayfa sıkıştırılmaz.

## 5. Dal durumu ve git kuralları

- ✅ 2026-10-21: `.gitignore` kökte. `venv/`, `.env`, `*.qcow2`, `*.img`, `*.vmdk`, `*.vdi`, geçici k6 `*.log` ve LaTeX artıkları (`*.aux`, `*.log`, `*.out`, `*.toc`) dışarıda. Ham k6 JSON ve `report.pdf` dışarıda değil.
- ✅ `README.md` çalıştırma, k6 komutları ve sonuç tablosunu taşıyor.
- ⏭️ `Project/` hâlâ git deposu değil (`git rev-parse` 2026-10-21: not a git repository). Dal, uzak ve commit yok. Depo öğrencinin komutuyla açılır.
- 🔒 Commit ve push yalnız öğrencinin açık komutuyla. `main`'e kendiliğinden merge yok.
- 🔒 Sırlar repoya girmez: `.env`, erişim anahtarı, özel anahtar, `.pem`, bulut kimlik bilgisi.
- Repoya girer: kaynak, Dockerfile, provision, k6 betiği, ham summary JSON, türetilmiş tablo, LaTeX, `report.pdf`, `README.md`, slayt kaynağı.
- 🔒 `../` altında yazma ve silme yok.

### 🔶 Commit'lenmemiş çalışma

Çalışma ağacı git ile izlenmiyor. `HAFIZA.md`, `README.md`, `.gitignore`, `app/`, `load-tests/`, `vm-setup/` ve `paper/` diskte duruyor. Commit beklemiyor; öğrenci istemedi.

### ⏭️ Açık kalan

1. Öğrenci kimliği — `paper/report.tex` yazar bloğu — ad, numara ve e-posta öğrenciden gelecek. Uydurulmadı.
2. GitHub kullanıcı adı ve depo URL'si — ek — depo henüz yok. Sahte URL yazılmadı.
3. Ubuntu ölçüm konağının CPU, RAM ve `uname -r` çıktısı — metodoloji tablosu — ölçüm günü yazılır, tahmin edilmez.
4. Eşik temiz üçlü — `load-tests/results/docker/` ve `results/vm/` — Docker run 3 p95 aştı; VM üç turda hata oranı ve p95 eşiği aştı.
5. VirtualBox NEM — `sen421-topic2` — VT-x yok, initramfs'te kaldı; ölçüm QEMU/WHPX ile alındı.
6. Öğrencinin fiyat listesi satırlarını ve LaTeX taslağını doğrulaması — `paper/report.tex` — taslak 2026-10-21'de yazıldı, teslim metni öğrencinin kontrolünden sonra olur.
7. AI tablosundaki seviyelerin öğrenci tarafından onaylanması — `paper/report.tex` Table IV — asistan 2 ve 4 yazdı; öğrenci kendi kullanımına göre değiştirir.

## 6. Değişmez kurallar — özet

Tam metin yönerge PDF'indedir. Burada yalnız uygulama özeti durur.

1. Bireysel iş. Başkasının tasarısı, kodu, şekli veya sonucu kaynak göstermeden alınmaz. Başka dersten proje taşınmaz.
2. En az iki alternatif: Ubuntu VM ve Docker konteyneri. Aynı uygulama, aynı k6 yükü, aynı CPU ve bellek tavanı.
3. Her performans hücresi en az üç bağımsız koşu, ortalama ve standart sapma. Tek koşu yasak.
4. Mimari şema öğrenci tarafından diagrams.net ile çizilir. Oklar istek yönünü gösterir. Şekil ve tablo metinde anılır (`Fig.~\ref`, `Table~\ref`).
5. Bedel iki katmanlıdır: gerçekleşen deney bedeli (kaynak yoksa 0 USD) ve §3'teki AWS projeksiyonu. Kaynaklar silinmiş ya da hiç açılmamış olmalıdır.
6. Paylaşılan sorumluluk ve KVKK Discussion'da durur. Kişisel veri yüklenmez. Yük testi yalnız öğrencinin kendi sürecine gider.
7. Rapor IEEEtran `conference,a4paper`, iki sütun, 6–8 sayfa, en çok 10. Özet 150–250 sözcük; özette simge, özel karakter, dipnot ve matematik yok. Anahtar sözcükler beş tanedir: cloud computing, virtualization, Docker containers, performance benchmarking, shared responsibility.
8. Kaynakça IEEE, en az 4 en çok 6 kaynak, içlerinde resmi sağlayıcı belgesi. Web kaynağında erişim tarihi vardır. Okunmamış kaynak yazılmaz. Başlangıç adayları: NIST SP 800-145, West Cloud+ 2. baskı, Docker belgesi, VirtualBox belgesi, k6 belgesi, AWS EC2 `t3.micro` ve AWS Fargate fiyat belgesi. Aday, kaynakça satırı değildir.
9. AI beyanı kaynakçadan önce zorunludur. Araç yazar veya olgu kaynağı diye yazılmaz. 2026-10-20'de bu hafıza ve `app/` bir kod asistanıyla yazıldı; raporda "hiçbir AI aracı kullanılmadı" denemez. Seviye 5–6 kabul sınırının dışında sayılabilir.
10. Sırlar, canlı bulut kaynakları ve Windows Docker Desktop ölçümü yok. Kenar boşluğuyla sayfa kazanılmaz. Sunum yapılmadan not yoktur.

Rapor bölüm sırası TeX iskeletinden gelir ve değişmez: Title/Abstract, Introduction, Background and Related Work, System Design, Methodology, Results, Discussion, Conclusion and Future Work, AI Tool Use and Originality Declaration, References, Appendix. Ek 10 sayfanın içindedir. Ekte kısa koşu betiği ve depo bağlantısı durur; anahtar durmaz.

Slayt sırası (8 slayt, 6–10 aralığında): başlık ve Topic 2; soru; mimari şema; yöntem; gecikme ve verim; boyut, açılış, bellek; bedel, sorumluluk, KVKK; öneri, sınır, gelecek iş. Canlı demo gerekmez. Ekran görüntüsü tercih edilir. Slayttaki her rakamı sözlü açıklamak gerekir.

Puan dağılımı, eforun nereye gideceğini gösterir: soru 2, arka plan 1,5, tasarım ve yöntem 3,5, sonuçlar 4, tartışma 3, kanıt 1, iletişim 3, sözlü anlayış 2.

## 7. Faz durumu

| Dilim | Durum |
|---|---|
| Hafıza ve kilitli kapsam | ✅ 2026-10-21 teslim notu işlendi |
| `app/` REST API ve Dockerfile | ✅ Uçlar doğrulandı; `sen421-api:latest` ve `/health` 200 |
| `vm-setup/` provision ve systemd | ✅ QEMU/WHPX üzerinde API ayakta. VirtualBox NEM başarısız; sınır olarak duruyor |
| `load-tests/` k6, koşucu, aggregate | ✅ Docker ve VM JSON'ları yazıldı. `aggregate.py` yok; sapma raporda `n-1` ile hesaplandı |
| Üçlü ölçüm ve sonuç tablosu | ✅ Tablo `report.pdf` içinde. İki tarafta da eşik aşımı var; sayılar duruyor |
| AWS projeksiyonu | ✅ Fiyat listesi 21 Ekim 2026: EC2 28.35872 USD, Fargate 28.05707 USD |
| `paper/report.tex` ve `report.pdf` | ✅ Tectonic derlemesi, 5 sayfa. Şema TikZ. diagrams.net dosyası yok. Yazar adı uydurulmadı |
| `paper/slides.md` | ✅ 8 slayt: başlık, soru, mimari grafik, yöntem, gecikme, boyut, bedel, sonuç. Slayt PDF basılmadı |
| `README.md` ve `.gitignore` | ✅ 2026-10-21 yazıldı |
| Teslim listesi | ⏭️ Ad, GitHub URL, diagrams.net ve slayt PDF hâlâ açık |

Teslimde duranlar: `paper/report.pdf` (5 sayfa), AI beyanı, tarihli fiyat listesi, sır yok, bulut kaynağı açılmadı, şekil ve tablo metinde anılı, IEEE atıf, 243 sözcük özet. Açık kalanlar: slayt PDF, GitHub veya ZIP, diagrams.net dosyası, öğrenci adı, öğrencinin kendi teslim cümleleri.

### Karşılaştırma (2026-10-21)

k6 2.2.0, 50 VU, 30 s, `/compute` ve `/payload`. Üç tur, arada 15 s. Sapma `n-1`. Eşik: HTTP 200 > %99 ve p95 < 500 ms. İki tarafta da en az bir tur eşiği aştı; sayılar silinmedi.

| Metrik | Docker | VM (QEMU/WHPX) |
|---|---|---|
| Medyan gecikme (ms) | 224.121 ± 75.998 | 214.347 ± 70.009 |
| p95 gecikme (ms) | 585.389 ± 194.322 | 734.976 ± 67.310 |
| İstek/s | 174.925 ± 8.026 | 157.792 ± 6.847 |
| Hata oranı (%) | JSON'da yok | 5.977 ± 1.149 |
| İmaj / disk | `docker images` 208 MB; `inspect` Size 52115316 bayt (49.701 MiB) | dosya 2792423424 bayt (2.792 GB); sanal boyut 64 GiB |
| Açılış (s) | 1.450 ± 0.221 | 47.660 ± 6.244 |

Docker turları: medyan 255.423, 279.468, 137.472; p95 465.741, 480.823, 809.605; istek/s 183.065, 174.694, 167.018. Run 3 yalnız p95 eşiğini aştı. `failed_pct` o JSON'larda yok.

VM turları (`load-tests/results/vm/`): medyan 268.268, 135.227, 239.547; p95 760.030, 786.166, 658.733; istek/s 150.523, 164.119, 158.732; hata %6.471, %6.796, %4.664. Üç turda da `http_200` ve p95 eşikleri düştü.

Docker açılış (`docker stop` sonra `docker start`, sağlık 200): 1.704, 1.303, 1.342 s. VM açılış (QEMU süreci kapandıktan sonra yeniden başlayıp `http://127.0.0.1:8000/health` 200): 48.566, 41.013, 53.401 s. Konuk adresi 10.0.2.15; konak ölçümü 127.0.0.1:8000 yönlendirmesinden.

Mimari not: VirtualBox 7.2.22, VT-x kapalı olduğu için NEM'e düştü ve Ubuntu initramfs'te `Begin: loading essential drivers` satırında kaldı. Ölçülen VM, aynı `ubuntu-24.04-amd64-disk001.vmdk` diskinin QEMU 11.1.0 WHPX (`-accel whpx,kernel-irqchip=off`, 2 vCPU, 2048 MiB) ile açılmış halidir. Bu bir Type-2 hipervizör çözümüdür; Docker Desktop WSL2 ölçümü gibi paylaşılan çekirdek iddiası değildir.

Docker bellek örneği duruyor: boşta %0.40 CPU ve 93.08 MiB; yükte tepe %201.52 CPU ve 99.54 MiB (`load-tests/results/docker/stats.csv`).

### Açık kalan ürün kararları (öğrencide)

- **Karar:** rapordaki ad, numara, e-posta.
- **Karar:** GitHub deposunun adı ve görünürlüğü.
- **Karar:** AI tablosundaki 0–6 seviyeleri ve hangi aracın hangi aşamada kullanıldığı.
- **İş:** §3'te kilitlenen kod, ölçüm, hesap makinesi ve LaTeX. Bunlar karar değildir; üretilecek iştir.
- **Karar sayılmayan kilitler** (2026-10-20): Topic 2 Part A, başlık, soru, VirtualBox + Docker Engine, Ubuntu 24.04 misafir, 2 vCPU / 2048 MiB, FastAPI/uvicorn 2 worker, `/health`, `/compute`, `/payload`, k6 50 VU / 30 sn / 3 koşu / 15 sn ara, `n-1` sapma, `eu-central-1`, `t3.micro` ve iki Fargate şekli, sentetik veri, AWS'de kaynak açmama. 1024 MiB ve Flask kilidi aynı gün öğrenci kararıyla kapandı.

## 8. Geliştirme standartları

- Kod, betik ve LaTeX yorumları İngilizce. Yorum "ne yaptığını" değil, ölçümü neden böyle kurduğunu söyler. Hafıza Türkçe kalır.
- Konteyner tavanının tek yeri `app/docker-compose.yml` (2 vCPU, 2g, memswap 2g). VM tavanı aynı sayılardır. k6 VU ve süresi `load-tests/` yazılınca orada durur; compose içine kopyalanmaz.
- Kullanıcıya görünen ürün metni yoktur. API gövdesi sabittir.
- Dinleyici ve konteyner `run-repeated.sh` sonunda sökülür. Yarım kalan `docker run` bir sonraki soğuk açılışı kirletir.
- Yeni özellik açılmaz. Bu depo bir ürün değildir; soruyu cevaplayan en küçük uygulamadır.

### Token tasarrufu

- Önce bu dosya, sonra yalnız dokunulan klasör (`app/`, `load-tests/`, `vm-setup/` veya `paper/`).
- `../information_pdf/` yeniden okunmaz; ilgili cümle burada yoksa o zaman ilgili sayfa çekilir.
- `load-tests/results/` içindeki ham JSON'un tamamı sohbete dökülmez; `aggregate.py` çıktısı okunur.
- Sanal disk, `.venv`, `build/` ve günlük okunmaz.
- 🔴 Kod ile hafıza çelişirse kod hafızaya uydurulmaz. Önce bu dosya düzeltilir.

## 9. Sık kullanılan komutlar

Ölçüm komutları Ubuntu konağında çalışır. Aşağıdaki biçim niyettir; betikler yazılınca yollar birebir bunlardır.

```bash
python3 -m venv app/.venv && app/.venv/bin/pip install -r app/requirements.txt
app/.venv/bin/uvicorn main:app --app-dir app --host 0.0.0.0 --port 8000 --workers 2 --no-access-log

docker compose -f app/docker-compose.yml up --build -d

powershell -File vm-setup/setup-vm.ps1
powershell -File load-tests/run_benchmarks.ps1

cd paper && latexmk -pdf -interaction=nonstopmode report.tex
```

Sanal makineyi açıp sağlık ucunu beklemek `run-repeated.sh` içindedir. Ayrı bir "hızlı bakış" komutu ölçüm sayılmaz.

## 10. Oturum sonu ritüeli

1. Başlıktaki tarih ve tek cümle güncellenir.
2. Mimari değiştiyse §3, sözleşme değiştiyse uygulama tablosu, durum değiştiyse §5 ve §7 yazılır.
3. Yeni ⏭️ maddesi "ne, nerede, neden bekliyor" üçlüsüyle eklenir.
4. Koşu sayısı ve sapma hesabının durumu sayı ile yazılır.
5. Açık karar listesi taranır. Verilmiş karar kapanır; kapanış tarihi ve yeri yazılır.
6. Artık doğru olmayan satır silinir.

## 11. Bilinçli olarak yazılmayanlar

- Autoscaling, PaaS, FaaS ve ikinci bir bulut sağlayıcısı. Kubernetes yalnız gelecek iş cümlesidir; ölçülmedi.
- Kimlik doğrulama, veri tabanı, ürün zarfı, sayfalama, mock sunucu, tasarım sistemi.
- Canlı AWS, Azure veya GCP kaynağı. Bedel hesap makinesinden gelir.
- Windows Docker Desktop ölçümünü paylaşılan çekirdek kanıtı diye yazmak. Raporda sınır olarak durur.
- Uydurulmuş öğrenci adı, fiyat, gecikme veya ekran görüntüsü.
- Okunmamış akademik makale.
