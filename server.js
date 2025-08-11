const express = require('express');
const cors = require('cors');
const path = require('path');
const fs = require('fs');

const app = express();
const PORT = process.env.PORT || 3010;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static('public'));

// Ana sayfa
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// Basit kullanıcı veritabanı (gerçek uygulamada veritabanı kullanın)
// Kullanıcı bilgilerini config dosyasından yükle
let users = [];
try {
    users = require('./config/users');
} catch (error) {
    console.warn('Kullanıcı config dosyası bulunamadı, varsayılan kullanıcılar kullanılıyor');
    // Varsayılan kullanıcılar (sadece geliştirme için)
    users = [
        { email: 'demo', password: 'demo123' }
    ];
}

// Session storage (gerçek uygulamada Redis veya veritabanı kullanın)
const sessions = new Map();

// Giriş endpoint'i
app.post('/api/login', (req, res) => {
    const { email, password } = req.body;
    
    if (!email || !password) {
        return res.status(400).json({ error: 'Kullanıcı adı ve şifre gerekli' });
    }
    
    // Kullanıcıyı bul
    const user = users.find(u => u.email === email && u.password === password);
    
    if (!user) {
        return res.status(401).json({ error: 'Geçersiz kullanıcı adı veya şifre' });
    }
    
    // Session token oluştur
    const sessionToken = Math.random().toString(36).substring(2) + Date.now().toString(36);
    sessions.set(sessionToken, { email: user.email, timestamp: Date.now() });
    
    res.json({ 
        success: true, 
        message: 'Giriş başarılı',
        sessionToken: sessionToken,
        user: { email: user.email }
    });
});

// Çıkış endpoint'i
app.post('/api/logout', (req, res) => {
    const { sessionToken } = req.body;
    
    if (sessionToken && sessions.has(sessionToken)) {
        sessions.delete(sessionToken);
    }
    
    res.json({ success: true, message: 'Çıkış başarılı' });
});

// Session kontrolü middleware
function checkSession(req, res, next) {
    const sessionToken = req.headers['x-session-token'];
    
    if (!sessionToken || !sessions.has(sessionToken)) {
        return res.status(401).json({ error: 'Oturum geçersiz' });
    }
    
    // Session'ı güncelle
    const session = sessions.get(sessionToken);
    session.timestamp = Date.now();
    
    req.user = session;
    next();
}

// Kart verilerini yükle
function loadCardsData() {
    try {
        const data = fs.readFileSync(path.join(__dirname, 'data', 'cards.json'), 'utf8');
        return JSON.parse(data);
    } catch (error) {
        console.error('Kart verileri yüklenirken hata:', error);
        return { cards: [], metadata: { totalCards: 0, lastUpdated: new Date().toISOString(), version: "1.0" } };
    }
}

// Kart verilerini kaydet
function saveCardsData(data) {
    try {
        fs.writeFileSync(path.join(__dirname, 'data', 'cards.json'), JSON.stringify(data, null, 2), 'utf8');
        return true;
    } catch (error) {
        console.error('Kart verileri kaydedilirken hata:', error);
        return false;
    }
}

// Kart arama fonksiyonu
function searchCard(cardNumber) {
    const cardsData = loadCardsData();
    
    // Kart numarasını temizle (boşlukları kaldır)
    const cleanCardNumber = cardNumber.replace(/\s/g, '');
    
    const result = cardsData.cards.find(card => {
        return card.cardNumber === cleanCardNumber;
    });
    
    return result;
}

// API endpoint - kart arama (session kontrolü ile)
app.post('/api/process', checkSession, (req, res) => {
    const { inputValue } = req.body;
    
    if (!inputValue) {
        return res.status(400).json({ error: 'Kart numarası gerekli' });
    }
    
    try {
        // Sadece kart numarasını al (boşlukları temizle)
        const cardNumber = inputValue.trim().replace(/\s/g, '');
        
        // Kart arama
        const foundCard = searchCard(cardNumber);
        
        if (!foundCard) {
            res.json({ 
                success: true, 
                result: `Kart bulunamadı!\n\nGirilen kart numarası: ${inputValue.trim()}`,
                originalInput: inputValue,
                foundCard: null
            });
        } else {
            const resultText = `${foundCard.companyName} firması ${foundCard.cardType} kartı`;
            
            res.json({ 
                success: true, 
                result: resultText,
                originalInput: inputValue,
                foundCard: {
                    companyName: foundCard.companyName,
                    cardType: foundCard.cardType
                }
            });
        }
        
    } catch (error) {
        console.error('Kart arama hatası:', error);
        res.status(500).json({ 
            success: false, 
            error: 'Kart arama sırasında hata oluştu',
            originalInput: inputValue
        });
    }
});

app.listen(PORT, () => {
    console.log(`Sunucu http://localhost:${PORT} adresinde çalışıyor`);
});
