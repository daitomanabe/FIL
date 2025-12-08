import { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Download, Globe, MapPin, Info, ArrowDown, Github } from 'lucide-react';
import './App.css';

const content = {
  en: {
    title: "fil",
    subtitle: "Where Creative Threads Intertwine",
    desc: [
      `"fil" (pronounced "feel") means "thread" in French. It's a space where creators from various fields gather to spin threads of ideas and weave the fabric of new creation.`,
      `Run by Daito Manabe, this space aims to be a 21st-century salon where creators, artists, engineers, and musicians interact beyond boundaries. In our modern era, where technology and art converge, cross-disciplinary dialogue and collaboration are key to fostering innovation.`
    ],
    activities: {
      title: "Activities",
      items: [
        "Interdisciplinary workshops and talk sessions",
        "Exhibitions of art pieces utilizing cutting-edge technology",
        "Experimental music performances and live events",
        "Open spaces for prototyping and hackathons",
        "Opportunities for free interaction and collaboration among members"
      ]
    },
    location: {
      title: "Location",
      address: "xxxx, Shibuya-ku, Tokyo",
      note: "The address is kept private due to personal safety concerns. I’ve experienced incidents involving a stalker as well as theft of posters displayed at the entrance, so the location details are managed with strict confidentiality.",
      access: []
    },
    specs: {
      title: "Space Specifications",
      area: "150 square meters (approx. 1,615 sq ft)",
      elec: "Electricity: 20kW (10kW available)",
      floor: "Floor Load: ~290kg/m²",
      height: "Ceiling Height: 2.7m - 3.15m"
    },
    downloads: {
      title: "Downloads",
      model1: "Download Daikanyama Model (.obj)",
      model2: "Download Daikanyama Plan 2 (.obj)",
      saver: "Download macOS Screensaver (.pkg)"
    },
    github: "View on GitHub"
  },
  jp: {
    title: "fil",
    subtitle: "創造の糸が交差する場所",
    desc: [
      `「fil」(フィル)は、フランス語で「糸」を意味します。ここでは、さまざまな分野のクリエイターたちが音楽を中心に集い、アイデアという糸を紡ぎ、新たな創造の布を織り上げていく場所です。`,
      `真鍋大度が手掛けるこの革新的なスペースは、クリエーター、アーティスト、エンジニア、ミュージシャンが垣根を超えて交流する、21世紀型のサロンを目指しています。技術と芸術が融合する現代において、分野を超えた対話と協働がイノベーションを生み出す鍵となります。`
    ],
    activities: {
      title: "活動内容",
      items: [
        "分野横断的なワークショップとトークセッション",
        "最新テクノロジーを活用したアート作品の展示",
        "実験的な音楽パフォーマンスやライブイベント",
        "プロトタイピングやハッカソンのためのオープンスペース",
        "クリエーターの自由な交流とコラボレーションの機会"
      ]
    },
    location: {
      title: "施設情報",
      address: "東京都渋谷区xxxxxx",
      note: "住所は非公開とさせていただいております。ストーカー被害や、入り口に貼ってあるポスターの盗難などの被害が過去にあり、所在地については厳重に管理しております。",
      access: []
    },
    specs: {
      title: "利用仕様",
      area: "広さ: 150m²",
      elec: "電気容量: 20kW (利用可能: 約10kW)",
      floor: "床耐荷重: 一般的に290kg/m²程度",
      height: "天井高: 2.7m 〜 3.15m"
    },
    downloads: {
      title: "ダウンロード",
      model1: "代官山モデル (.obj)",
      model2: "代官山プラン2 (.obj)",
      saver: "macOS スクリーンセーバー (.pkg)"
    },
    github: "GitHubで見る"
  }
};

function App() {
  const [lang, setLang] = useState('en');
  const t = content[lang];

  return (
    <div className="app">
      <motion.div
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        transition={{ duration: 1 }}
      >
        <nav className="nav">
          <div className="logo">
            <img src="./assets/logo/logo.svg" alt="FIL Logo" style={{ height: '24px' }} />
          </div>
          <button
            className="lang-toggle"
            onClick={() => setLang(l => l === 'en' ? 'jp' : 'en')}
          >
            <Globe size={16} style={{ marginRight: 6 }} />
            {lang === 'en' ? 'JP' : 'EN'}
          </button>
        </nav>

        <header className="hero">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 1 }}
            className="hero-content"
          >
            <p className="subtitle">{t.subtitle}</p>
          </motion.div>

          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 1, duration: 1 }}
            className="scroll-indicator"
          >
            <ArrowDown size={24} />
          </motion.div>
        </header>

        <main className="main-content">
          <section className="intro">
            {t.desc.map((d, i) => (
              <motion.p
                key={i}
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ delay: i * 0.2 }}
              >
                {d}
              </motion.p>
            ))}

            <motion.div
              style={{ marginTop: '3rem', textAlign: 'center' }}
              initial={{ opacity: 0 }}
              whileInView={{ opacity: 1 }}
              viewport={{ once: true }}
            >
              <a
                href="https://github.com/daitomanabe/FIL"
                target="_blank"
                rel="noopener noreferrer"
                className="btn"
                style={{ display: 'inline-flex', alignItems: 'center', gap: '8px', background: '#333', color: '#fff' }}
              >
                <Github size={20} />
                {t.github}
              </a>
            </motion.div>
          </section>

          <section className="activities">
            <motion.h2
              initial={{ opacity: 0 }}
              whileInView={{ opacity: 1 }}
              viewport={{ once: true }}
            >
              {t.activities.title}
            </motion.h2>
            <ul>
              {t.activities.items.map((item, i) => (
                <motion.li
                  key={i}
                  initial={{ opacity: 0, x: -20 }}
                  whileInView={{ opacity: 1, x: 0 }}
                  viewport={{ once: true }}
                  transition={{ delay: i * 0.1 }}
                >
                  {item}
                </motion.li>
              ))}
            </ul>
          </section>

          <section className="gallery">
            <motion.div
              initial={{ opacity: 0 }}
              whileInView={{ opacity: 1 }}
              viewport={{ once: true }}
              className="image-grid"
            >
              <img src="./assets/images/A.png" alt="Layout A" />
              <img src="./assets/images/B2.png" alt="Layout B2" />
              <img src="./assets/images/B3.png" alt="Layout B3" />
            </motion.div>
          </section>

          <section className="specs">
            <div className="specs-grid">
              <div className="spec-card">
                <h3>{t.location.title}</h3>
                <p><MapPin size={16} style={{ display: 'inline', verticalAlign: 'text-bottom' }} /> {t.location.address}</p>
                <div className="access-list">
                  {t.location.access.map((a, i) => <div key={i} className="access-item">{a}</div>)}
                </div>
                <p className="note"><Info size={16} /> {t.location.note}</p>
              </div>

              <div className="spec-card">
                <h3>{t.specs.title}</h3>
                <p>{t.specs.area}</p>
                <p>{t.specs.height}</p>
                <p>{t.specs.elec}</p>
                <p>{t.specs.floor}</p>
              </div>
            </div>
          </section>

          <section className="downloads">
            <motion.h2
              initial={{ opacity: 0 }}
              whileInView={{ opacity: 1 }}
              viewport={{ once: true }}
            >
              {t.downloads.title}
            </motion.h2>
            <div className="download-buttons">
              <a href="./assets/3d/代官山.obj" download className="btn">
                <Download size={20} /> {t.downloads.model1}
              </a>
              <a href="./assets/3d/代官山 plan2.obj" download className="btn">
                <Download size={20} /> {t.downloads.model2}
              </a>
              <a href="https://github.com/daitomanabe/FIL/releases/download/v1.0.0/fil_screensaver.pkg" download className="btn" style={{ background: '#fff', color: '#000' }}>
                <Download size={20} /> {t.downloads.saver}
              </a>
            </div>
          </section>
        </main>

        <footer className="footer">
          <p>© 2025 FIL<br /><span style={{ opacity: 0.5, fontSize: '0.9em' }}>Logo design by <a href="https://davidrudnick.org/" target="_blank" rel="noopener noreferrer" style={{ color: 'inherit', borderBottom: '1px solid rgba(255,255,255,0.2)' }}>David Rudnick</a></span></p>
        </footer>
      </motion.div>
    </div>
  );
}

export default App;
