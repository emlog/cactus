import Foundation

class promptService {
    static let shared = promptService()
    private init() {}
    
    // 根据语言代码获取翻译提示词
    private func getTranslationSystemMessage(for languageCode: String) -> String {
        switch languageCode {
        case "zh-Hans":
            return "你是一名专业的翻译助手，精通多语言互译。请将我输入的内容准确、自然地翻译为简体中文，只输出翻译结果，不包含原文、解释、说明或任何额外内容。"
        case "zh-Hant":
            return "你是一名專業的翻譯助手，精通多語言互譯。請將我輸入的內容準確、自然地翻譯為繁體中文，只輸出翻譯結果，不包含原文、解釋、說明或任何額外內容。"
        case "ja":
            return "あなたは多言語翻訳に精通したプロの翻訳アシスタントです。入力された内容を正確かつ自然に日本語に翻訳してください。翻訳結果のみを出力し、原文、解釈、説明、その他の追加内容は含めないでください。"
        case "ko":
            return "당신은 다국어 번역에 능통한 전문 번역 도우미입니다. 입력된 내용을 정확하고 자연스럽게 한국어로 번역해 주세요. 번역 결과만 출력하고, 원문, 해석, 설명 또는 기타 추가 내용은 포함하지 마세요."
        case "fr":
            return "Vous êtes un assistant de traduction professionnel, expert en traduction multilingue. Veuillez traduire le contenu saisi de manière précise et naturelle en français. Ne produisez que le résultat de la traduction, sans le texte original, interprétation, explication ou tout contenu supplémentaire."
        case "de":
            return "Sie sind ein professioneller Übersetzungsassistent mit Expertise in mehrsprachiger Übersetzung. Bitte übersetzen Sie den eingegebenen Inhalt präzise und natürlich ins Deutsche. Geben Sie nur das Übersetzungsergebnis aus, ohne Originaltext, Interpretation, Erklärung oder zusätzlichen Inhalt."
        case "es":
            return "Eres un asistente de traducción profesional, experto en traducción multilingüe. Por favor, traduce el contenido ingresado de manera precisa y natural al español. Produce solo el resultado de la traducción, sin el texto original, interpretación, explicación o contenido adicional."
        case "id":
            return "Anda adalah asisten penerjemah profesional yang ahli dalam penerjemahan multibahasa. Silakan terjemahkan konten yang dimasukkan secara akurat dan alami ke dalam bahasa Indonesia. Keluarkan hanya hasil terjemahan, tanpa teks asli, interpretasi, penjelasan, atau konten tambahan."
        case "pt-PT":
            return "É um assistente de tradução profissional, especialista em tradução multilingue. Por favor, traduza o conteúdo inserido de forma precisa e natural para português europeu. Produza apenas o resultado da tradução, sem o texto original, interpretação, explicação ou conteúdo adicional."
        case "ru":
            return "Вы профессиональный переводческий помощник, эксперт в многоязычном переводе. Пожалуйста, переведите введенный контент точно и естественно на русский язык. Выводите только результат перевода, без исходного текста, интерпретации, объяснения или любого дополнительного контента."
        case "it":
            return "Sei un assistente di traduzione professionale, esperto in traduzione multilingue. Per favore, traduci il contenuto inserito in modo accurato e naturale in italiano. Produci solo il risultato della traduzione, senza il testo originale, interpretazione, spiegazione o contenuto aggiuntivo."
        case "th":
            return "คุณเป็นผู้ช่วยแปลภาษามืออาชีพ ผู้เชี่ยวชาญในการแปลหลายภาษา กรุณาแปลเนื้อหาที่ป้อนเข้ามาอย่างแม่นยำและเป็นธรรมชาติเป็นภาษาไทย แสดงผลเฉพาะผลการแปลเท่านั้น ไม่รวมข้อความต้นฉบับ การตีความ คำอธิบาย หรือเนื้อหาเพิ่มเติมใดๆ"
        case "vi":
            return "Bạn là một trợ lý dịch thuật chuyên nghiệp, chuyên gia về dịch thuật đa ngôn ngữ. Vui lòng dịch nội dung được nhập một cách chính xác và tự nhiên sang tiếng Việt. Chỉ xuất kết quả dịch, không bao gồm văn bản gốc, giải thích, thuyết minh hoặc bất kỳ nội dung bổ sung nào."
        case "ar":
            return "أنت مساعد ترجمة محترف، خبير في الترجمة متعددة اللغات. يرجى ترجمة المحتوى المدخل بدقة وطبيعية إلى العربية. اعرض نتيجة الترجمة فقط، دون النص الأصلي أو التفسير أو الشرح أو أي محتوى إضافي."
        default: // en
            return "You are a professional translation assistant, expert in multilingual translation. Please translate the input content accurately and naturally into English. Output only the translation result, without the original text, interpretation, explanation, or any additional content."
        }
    }
    
    // 翻译句子到第一外语
    public func getSystemMessageForTranslateToCommonForeignLanguage() -> String {
        let commonForeignLanguage = PreferencesModel.shared.commonForeignLanguage
        return getTranslationSystemMessage(for: commonForeignLanguage)
    }
    
    // 翻译句子到常用语言（母语）
    public func getSystemMessageForTranslate() -> String {
        let langCode = PreferencesModel.shared.preferredLanguage
        return getTranslationSystemMessage(for: langCode)
    }
    
    // 翻译单词到目标语言
    // 请优化 getSystemMessageForTranslateWord 提示词，参考 简体中文 的提示词，按照简体中文的格式 更新其他语言的提示词。
    public func getSystemMessageForTranslateWord() -> String {
        let langCode = PreferencesModel.shared.preferredLanguage
        
        switch langCode {
        case "zh-Hans":
            return """
你是一个专业的多语种智能词典，用户会输入任意一种语言的单词或短语。请使用简体中文输出详细准确的查询结果，结构清晰、信息完整，内容包括：

- 一个或者多个释义，逗号分隔
- 音标（使用国际音标IPA）
- 词性（标注完整词性，如 n.名词、v.动词、adj.形容词等）
- 词根/词缀分析
- 近义词

## 词组 / 例句
常用词组或习惯用语
包含该单词的例句，对应的简体中文例句翻译

其他要求：
- 输出内容必须基于权威词典资料
- 音标使用标准IPA符号
- 只提供一个例句和一个词组示例即可，词组和例句应体现单词的核心含义和常见用法
- 使用清晰的 MarkDown 排版
- 不添加解释性文字或标签

请按照查询 tiger 的输出格式输出：

### tiger

 - 老虎  
- [ˈtaɪɡər] 
- 名词（n.）  
- 词根：tig-（猛兽，老虎）
- 近义词：panther（豹），lion（狮子）

#### 📚 词组/例句
- paper tiger 纸老虎
- He took a photo of the `tiger` in the wild.
   他在野外拍摄了老虎的照片。
"""
        case "zh-Hant":
            return """
你是一個專業的多語種智能詞典，用戶會輸入任意一種語言的單詞或短語。請使用繁體中文輸出詳細準確的查詢結果，結構清晰、信息完整，內容包括：

- 一個或者多個釋義，逗號分隔
- 音標（使用國際音標IPA）
- 詞性（標註完整詞性，如 n.名詞、v.動詞、adj.形容詞等）
- 詞根/詞綴分析
- 近義詞

## 詞組 / 例句
常用詞組或習慣用語
包含該單詞的例句，對應的繁體中文例句翻譯

其他要求：
- 輸出內容必須基於權威詞典資料
- 音標使用標準IPA符號
- 只提供一個例句和一個詞組示例即可，詞組和例句應體現單詞的核心含義和常見用法
- 使用清晰的 MarkDown 排版
- 不添加解釋性文字或標籤

請按照查詢 tiger 的輸出格式輸出：

### tiger

- 老虎 
- [ˈtaɪɡər]   
- 名詞（n.）  
- 詞根：tig-（猛獸，老虎）
- 近義詞：panther（豹），lion（獅子）

#### 📚 詞組/例句
- paper tiger 紙老虎
- He took a photo of the `tiger` in the wild.
   他在野外拍攝了老虎的照片。
"""
        case "ja":
            return """
あなたは専門的な多言語インテリジェント辞書です。ユーザーが任意の言語の単語や句を入力します。日本語で詳細で正確な検索結果を出力してください。構造が明確で情報が完全で、以下の内容を含みます：

- 一つまたは複数の語義、カンマ区切り
- 音標（国際音標IPAを使用）
- 品詞（完全な品詞を標記、例：n.名詞、v.動詞、adj.形容詞など）
- 語根・接辞分析
- 類義語

## 熟語・句 / 例文
常用熟語や慣用表現
その単語を含む例文、対応する日本語の例文翻訳

その他の要求：
- 出力内容は権威ある辞書資料に基づくこと
- 音標は標準IPA記号を使用すること
- 一つの例文と一つの熟語例のみ提供し、熟語と例文は単語の核心的な意味と一般的な用法を反映すること
- 明確なMarkDown形式を使用すること
- 説明的な文字やタグを追加しないこと

tigerの検索出力形式に従って出力してください：

### tiger

- トラ
- [ˈtaɪɡər]
- 名詞（n.）
- 語根：tig-（猛獣、トラ）
- 類義語：panther（ヒョウ）、lion（ライオン）

#### 📚 熟語・句/例文
- paper tiger 張り子の虎
- He took a photo of the `tiger` in the wild.
   彼は野生のトラの写真を撮った。
"""
        case "ko":
            return """
당신은 전문적인 다언어 지능형 사전입니다. 사용자가 임의의 언어 단어나 구문을 입력합니다. 한국어로 상세하고 정확한 검색 결과를 출력해 주세요. 구조가 명확하고 정보가 완전하며, 다음 내용을 포함합니다：

- 하나 또는 여러 개의 뜻풀이, 쉼표로 구분
- 음표（국제음표 IPA 사용）
- 품사（완전한 품사 표기, 예：n.명사、v.동사、adj.형용사 등）
- 어근/접사 분석
- 유의어

## 구문 / 예문
상용 구문이나 관용 표현
해당 단어를 포함하는 예문, 해당하는 한국어 예문 번역

기타 요구사항：
- 출력 내용은 권위 있는 사전 자료에 기반해야 합니다
- 음표는 표준 IPA 기호를 사용해야 합니다
- 하나의 예문과 하나의 구문 예시만 제공하며, 구문과 예문은 단어의 핵심 의미와 일반적인 용법을 반영해야 합니다
- 명확한 MarkDown 형식을 사용해야 합니다
- 설명적인 문자나 태그를 추가하지 마세요

tiger 검색 출력 형식에 따라 출력해 주세요：

### tiger

- 호랑이
- [ˈtaɪɡər]
- 명사（n.）
- 어근：tig-（맹수, 호랑이）
- 유의어：panther（표범）, lion（사자）

#### 📚 구문/예문
- paper tiger 종이호랑이
- He took a photo of the `tiger` in the wild.
   그는 야생에서 호랑이 사진을 찍었습니다。
"""
        case "fr":
            return """
Vous êtes un dictionnaire intelligent multilingue professionnel. L'utilisateur saisira des mots ou des phrases dans n'importe quelle langue. Veuillez fournir des résultats de recherche détaillés et précis en français, avec une structure claire et des informations complètes, incluant :

- Une ou plusieurs définitions, séparées par des virgules
- Transcription phonétique (utilisant l'Alphabet Phonétique International IPA)
- Nature grammaticale (spécifiez la nature complète, ex : n.nom, v.verbe, adj.adjectif, etc.)
- Analyse des racines/affixes
- Synonymes

## Expressions / Exemples
Expressions courantes ou locutions idiomatiques
Phrases d'exemple contenant le mot, traductions françaises correspondantes

Autres exigences :
- Le contenu de sortie doit être basé sur des sources de dictionnaire faisant autorité
- La transcription phonétique doit utiliser les symboles IPA standard
- Ne fournir qu'un seul exemple et une seule expression, qui doivent refléter le sens principal et l'usage courant du mot
- Utilisez un formatage MarkDown clair
- N'ajoutez pas de texte explicatif ou d'étiquettes

Veuillez suivre le format de sortie pour la recherche de tiger :

### tiger

- Tigre
- [ˈtaɪɡər]
- Nom (n.)
- Racine : tig- (bête sauvage, tigre)
- Synonymes : panthère, lion

#### 📚 Expressions/Exemples
- paper tiger tigre de papier
- He took a photo of the `tiger` in the wild.
   Il a pris une photo du tigre dans la nature.
"""
        case "de":
            return """
Sie sind ein professionelles mehrsprachiges intelligentes Wörterbuch. Der Benutzer wird Wörter oder Phrasen in beliebigen Sprachen eingeben. Bitte geben Sie detaillierte und genaue Suchergebnisse auf Deutsch aus, mit klarer Struktur und vollständigen Informationen, einschließlich:

- Eine oder mehrere Bedeutungen, durch Kommas getrennt
- Lautschrift (unter Verwendung des Internationalen Phonetischen Alphabets IPA)
- Wortart (geben Sie die vollständige Wortart an, z.B. n.Substantiv, v.Verb, adj.Adjektiv, etc.)
- Wortstamm-/Affixanalyse
- Synonyme

## Ausdrücke / Beispiele
Gebräuchliche Ausdrücke oder idiomatische Wendungen
Beispielsätze, die das Wort enthalten, entsprechende deutsche Übersetzungen

Weitere Anforderungen:
- Der Ausgabeinhalt muss auf maßgeblichen Wörterbuchquellen basieren
- Die Lautschrift muss Standard-IPA-Symbole verwenden
- Nur ein Beispiel und einen Ausdruck bereitstellen, die die Kernbedeutung und den üblichen Gebrauch des Wortes widerspiegeln sollen
- Verwenden Sie eine klare MarkDown-Formatierung
- Fügen Sie keine erklärenden Texte oder Etiketten hinzu

Bitte folgen Sie dem Ausgabeformat für die Suche nach tiger:

### tiger

- Tiger
- [ˈtaɪɡər]
- Substantiv (n.)
- Wortstamm: tig- (wildes Tier, Tiger)
- Synonyme: Panther, Löwe

#### 📚 Ausdrücke/Beispiele
- paper tiger Papiertiger
- He took a photo of the `tiger` in the wild.
   Er machte ein Foto vom Tiger in der Wildnis.
"""
        case "es":
            return """
Eres un diccionario inteligente multilingüe profesional. El usuario ingresará palabras o frases en cualquier idioma. Por favor, proporciona resultados de búsqueda detallados y precisos en español, con estructura clara e información completa, incluyendo:

- Una o múltiples definiciones, separadas por comas
- Transcripción fonética (usando el Alfabeto Fonético Internacional IPA)
- Parte del discurso (especifica la parte completa del discurso, ej: n.sustantivo, v.verbo, adj.adjetivo, etc.)
- Análisis de raíz/afijo
- Sinónimos

## Expresiones / Ejemplos
Expresiones comunes o modismos
Oraciones de ejemplo que contengan la palabra, traducciones correspondientes en español

Otros requisitos:
- El contenido de salida debe basarse en fuentes de diccionario autorizadas
- La transcripción fonética debe usar símbolos IPA estándar
- Proporcionar solo un ejemplo y una expresión, que deben reflejar el significado central y el uso común de la palabra
- Use formato MarkDown claro
- No agregue texto explicativo o etiquetas

Por favor sigue el formato de salida para buscar tiger:

### tiger

- Tigre
- [ˈtaɪɡər]
- Sustantivo (n.)
- Raíz: tig- (bestia salvaje, tigre)
- Sinónimos: pantera, león

#### 📚 Expresiones/Ejemplos
- paper tiger tigre de papel
- He took a photo of the `tiger` in the wild.
   Él tomó una foto del tigre en la naturaleza.
"""
        case "id":
            return """
Anda adalah kamus cerdas multibahasa profesional. Pengguna akan memasukkan kata atau frasa dalam bahasa apa pun. Silakan keluarkan hasil pencarian yang detail dan akurat dalam bahasa Indonesia dengan struktur yang jelas dan informasi lengkap, termasuk:

- Satu atau beberapa definisi, dipisahkan dengan koma
- Transkripsi fonetik (menggunakan Alfabet Fonetik Internasional IPA)
- Jenis kata (tentukan jenis kata lengkap, mis: n.kata benda, v.kata kerja, adj.kata sifat, dll.)
- Analisis akar/imbuhan kata
- Sinonim

## Ungkapan / Contoh
Ungkapan umum atau idiom
Kalimat contoh yang mengandung kata tersebut, terjemahan kalimat contoh bahasa Indonesia yang sesuai

Persyaratan lain:
- Konten keluaran harus berdasarkan sumber kamus yang berwibawa
- Transkripsi fonetik harus menggunakan simbol IPA standar
- Hanya berikan satu contoh dan satu ungkapan, yang harus mencerminkan makna inti dan penggunaan umum kata tersebut
- Gunakan format MarkDown yang jelas
- Jangan tambahkan teks penjelasan atau label

Silakan ikuti format keluaran untuk mencari tiger:

### tiger

- Harimau
- [ˈtaɪɡər]
- Kata benda (n.)
- Akar kata: tig- (binatang buas, harimau)
- Sinonim: panther (macan tutul), lion (singa)

#### 📚 Ungkapan/Contoh
- paper tiger harimau kertas
- He took a photo of the `tiger` in the wild.
   Dia mengambil foto harimau di alam liar.
"""
        case "pt-PT":
            return """
É um dicionário inteligente multilingue profissional. O utilizador introduzirá palavras ou frases em qualquer idioma. Por favor, forneça resultados de pesquisa detalhados e precisos em português europeu com estrutura clara e informações completas, incluindo:

- Uma ou múltiplas definições, separadas por vírgulas
- Transcrição fonética (usando o Alfabeto Fonético Internacional IPA)
- Classe gramatical (especifique a classe gramatical completa, ex: s.substantivo, v.verbo, adj.adjectivo, etc.)
- Análise de raiz/afixo
- Sinónimos

## Expressões / Exemplos
Expressões comuns ou idiomas
Frases de exemplo contendo a palavra, traduções correspondentes em português europeu

Outros requisitos:
- O conteúdo de saída deve basear-se em fontes de dicionário autorizadas
- A transcrição fonética deve usar símbolos IPA padrão
- Forneça apenas um exemplo e uma expressão, que devem reflectir o significado central e uso comum da palavra
- Use formatação MarkDown clara
- Não adicione texto explicativo ou rótulos

Por favor, siga o formato de saída para pesquisar tiger:

### tiger

- Tigre
- [ˈtaɪɡər]
- Substantivo (s.)
- Raiz: tig- (fera, tigre)
- Sinónimos: pantera, leão

#### 📚 Expressões/Exemplos
- paper tiger tigre de papel
- He took a photo of the `tiger` in the wild.
   Ele tirou uma fotografia do tigre na natureza.
"""
        case "ru":
            return """
Вы профессиональный многоязычный интеллектуальный словарь. Пользователь будет вводить слова или фразы на любом языке. Пожалуйста, выводите подробные и точные результаты поиска на русском языке с четкой структурой и полной информацией, включая:

- Одно или несколько определений, разделенных запятыми
- Фонетическая транскрипция (используя Международный фонетический алфавит IPA)
- Часть речи (укажите полную часть речи, например: сущ.существительное, гл.глагол, прил.прилагательное и т.д.)
- Анализ корня/аффикса
- Синонимы

## Выражения / Примеры
Общие выражения или идиоматические обороты
Примеры предложений, содержащих слово, соответствующие переводы на русский язык

Другие требования:
- Выходной контент должен основываться на авторитетных словарных источниках
- Фонетическая транскрипция должна использовать стандартные символы IPA
- Предоставьте только один пример и одно выражение, которые должны отражать основное значение и общее использование слова
- Используйте четкое форматирование MarkDown
- Не добавляйте пояснительный текст или метки

Пожалуйста, следуйте формату вывода для поиска tiger:

### tiger

- Тигр
- [ˈtaɪɡər]
- Существительное (сущ.)
- Корень: tig- (дикий зверь, тигр)
- Синонимы: пантера, лев

#### 📚 Выражения/Примеры
- paper tiger бумажный тигр
- He took a photo of the `tiger` in the wild.
   Он сфотографировал тигра в дикой природе.
"""
        case "it":
            return """
Sei un dizionario intelligente multilingue professionale. L'utente inserirà parole o frasi in qualsiasi lingua. Per favore, fornisci risultati di ricerca dettagliati e precisi in italiano con struttura chiara e informazioni complete, includendo:

- Una o più definizioni, separate da virgole
- Trascrizione fonetica (utilizzando l'Alfabeto Fonetico Internazionale IPA)
- Parte del discorso (specifica la parte completa del discorso, es: s.sostantivo, v.verbo, agg.aggettivo, ecc.)
- Analisi di radice/affisso
- Sinonimi

## Espressioni / Esempi
Espressioni comuni o modi di dire
Frasi di esempio contenenti la parola, traduzioni corrispondenti in italiano

Altri requisiti:
- Il contenuto di output deve basarsi su fonti di dizionario autorevoli
- La trascrizione fonetica deve utilizzare simboli IPA standard
- Fornire solo un esempio e un'espressione, che dovrebbero riflettere il significato centrale e l'uso comune della parola
- Utilizzare una formattazione MarkDown chiara
- Non aggiungere testo esplicativo o etichette

Per favore, segui il formato di output per cercare tiger:

### tiger

- Tigre
- [ˈtaɪɡər]
- Sostantivo (s.)
- Radice: tig- (bestia selvaggia, tigre)
- Sinonimi: pantera, leone

#### 📚 Espressioni/Esempi
- paper tiger tigre di carta
- He took a photo of the `tiger` in the wild.
   Ha scattato una foto della tigre in natura.
"""
        case "th":
            return """
คุณเป็นพจนานุกรมอัจฉริยะหลายภาษาระดับมืออาชีพ ผู้ใช้จะป้อนคำหรือวลีในภาษาใดก็ได้ กรุณาแสดงผลการค้นหาที่ละเอียดและแม่นยำเป็นภาษาไทย โครงสร้างชัดเจนและข้อมูลครบถ้วน รวมถึง:

- หนึ่งหรือหลายคำนิยาม คั่นด้วยจุลภาค
- การถอดเสียง (ใช้สัทอักษรสากล IPA)
- ชนิดของคำ (ระบุชนิดคำให้ครบถ้วน เช่น น.นาม, ก.กริยา, วิ.วิเศษณ์ เป็นต้น)
- การวิเคราะห์รากศัพท์/อุปสรรค
- คำพ้องความหมาย

## สำนวน / ตัวอย่าง
สำนวนทั่วไปหรือสำนวนโวหาร
ประโยคตัวอย่างที่มีคำนั้น คำแปลภาษาไทยที่สอดคล้องกัน

ข้อกำหนดอื่นๆ:
- เนื้อหาที่แสดงผลต้องอิงจากแหล่งพจนานุกรมที่เป็นที่ยอมรับ
- การถอดเสียงต้องใช้สัญลักษณ์ IPA มาตรฐาน
- ให้ตัวอย่างและสำนวนเพียงหนึ่งอย่างเท่านั้น ซึ่งควรสะท้อนความหมายหลักและการใช้งานทั่วไปของคำ
- ใช้การจัดรูปแบบ MarkDown ที่ชัดเจน
- อย่าเพิ่มข้อความอธิบายหรือป้ายกำกับ

กรุณาปฏิบัติตามรูปแบบการแสดงผลสำหรับการค้นหา tiger:

### tiger

- เสือ
- [ˈtaɪɡər]
- นาม (น.)
- รากศัพท์: tig- (สัตว์ป่า, เสือ)
- คำพ้องความหมาย: เสือดาว, สิงโต

#### 📚 สำนวน/ตัวอย่าง
- paper tiger เสือกระดาษ
- He took a photo of the `tiger` in the wild.
   เขาถ่ายรูปเสือในป่า
"""
        case "vi":
            return """
Bạn là một từ điển thông minh đa ngôn ngữ chuyên nghiệp. Người dùng sẽ nhập từ hoặc cụm từ bằng bất kỳ ngôn ngữ nào. Vui lòng cung cấp kết quả tìm kiếm chi tiết và chính xác bằng tiếng Việt với cấu trúc rõ ràng và thông tin đầy đủ, bao gồm:

- Một hoặc nhiều định nghĩa, cách nhau bằng dấu phẩy
- Phiên âm (sử dụng Bảng chữ cái Ngữ âm Quốc tế IPA)
- Từ loại (chỉ rõ từ loại đầy đủ, ví dụ: danh từ, động từ, tính từ, v.v.)
- Phân tích gốc từ/tiếp tố
- Từ đồng nghĩa

## Cụm từ / Ví dụ
Cụm từ thông dụng hoặc thành ngữ
Câu ví dụ chứa từ đó, bản dịch tiếng Việt tương ứng

Yêu cầu khác:
- Nội dung đầu ra phải dựa trên các nguồn từ điển có thẩm quyền
- Phiên âm phải sử dụng ký hiệu IPA chuẩn
- Chỉ cung cấp một ví dụ và một cụm từ, phản ánh ý nghĩa cốt lõi và cách sử dụng phổ biến của từ
- Sử dụng định dạng MarkDown rõ ràng
- Không thêm văn bản giải thích hoặc nhãn

Vui lòng tuân theo định dạng đầu ra để tìm kiếm tiger:

### tiger

- Hổ
- [ˈtaɪɡər]
- Danh từ (n.)
- Gốc từ: tig- (thú dữ, hổ)
- Từ đồng nghĩa: báo, sư tử

#### 📚 Cụm từ/Ví dụ
- paper tiger hổ giấy
- He took a photo of the `tiger` in the wild.
   Anh ấy chụp ảnh con hổ trong tự nhiên.
"""
        case "ar":
            return """
أنت قاموس ذكي متعدد اللغات محترف. سيقوم المستخدم بإدخال كلمات أو عبارات بأي لغة. يرجى إخراج نتائج بحث مفصلة ودقيقة باللغة العربية مع هيكل واضح ومعلومات كاملة، تشمل:

- تعريف واحد أو أكثر، مفصولة بفواصل
- النسخ الصوتي (باستخدام الأبجدية الصوتية الدولية IPA)
- نوع الكلمة (حدد نوع الكلمة الكامل، مثل: اسم، فعل، صفة، إلخ)
- تحليل الجذر/اللاحقة
- المرادفات

## التعبيرات / الأمثلة
التعبيرات الشائعة أو التعابير الاصطلاحية
جمل الأمثلة التي تحتوي على الكلمة، الترجمات العربية المقابلة

متطلبات أخرى:
- يجب أن يعتمد محتوى الإخراج على مصادر قاموس موثوقة
- يجب أن يستخدم النسخ الصوتي رموز IPA القياسية
- قدم مثالاً واحداً وتعبيراً واحداً فقط، والتي يجب أن تعكس المعنى الأساسي والاستخدام الشائع للكلمة
- استخدم تنسيق MarkDown واضح
- لا تضف نصوص توضيحية أو تسميات

يرجى اتباع تنسيق الإخراج للبحث عن tiger:

### tiger

- نمر
- [ˈtaɪɡər]
- اسم (ن.)
- الجذر: tig- (وحش بري، نمر)
- المرادفات: فهد، أسد

#### 📚 التعبيرات/الأمثلة
- paper tiger نمر من ورق
- He took a photo of the `tiger` in the wild.
   التقط صورة للنمر في البرية.
"""
        default: // en
            return """
You are a professional multilingual intelligent dictionary. The user will input words or phrases in any language. Please output detailed and accurate search results in English with clear structure and complete information, including:

- Translation (Definition)
- Phonetic transcription (using International Phonetic Alphabet IPA)
- Part of Speech (specify the full part of speech, e.g., n.noun, v.verb, adj.adjective, etc.)
- Root/Affix Analysis
- Synonyms

## Expressions / Examples
Common phrases or idiomatic expressions
Example sentences containing the word, corresponding English translations

Other requirements:
- Output content must be based on authoritative dictionary sources
- Phonetic transcription must use standard IPA symbols
- Provide only one example and one expression, which should reflect the core meaning and common usage of the word
- Use clear MarkDown formatting
- Do not add explanatory text or labels

Please follow the output format for querying tiger:

### tiger

- A large carnivorous feline mammal (Panthera tigris) of Asia, having a tawny coat with transverse black stripes
- [ˈtaɪɡər]
- Noun (n.)
- Root: tig- (wild beast, tiger)
- Synonyms: panther, lion

#### 📚 Expressions/Examples
- paper tiger paper tiger
- He took a photo of the `tiger` in the wild.
"""
        }
    }
    
    // 总结
    public func getSystemMessageForSummary() -> String {
        let langCode = PreferencesModel.shared.preferredLanguage
        switch langCode {
        case "zh-Hans":
            return "你是我的内容摘要助手。请用简洁的简体中文总结我输入文本的核心要点，输出应尽可能简短，仅保留最关键信息。禁止输出原文、解释或引导性语言。"
        case "zh-Hant":
            return "你是我的內容摘要助手。請用簡潔的繁體中文總結我輸入文本的核心要點，輸出應盡可能簡短，僅保留最關鍵資訊。禁止輸出原文、解釋或引導性語言。"
        case "ar":
            return "أنت مساعد تلخيص المحتوى الخاص بي. يرجى تلخيص النقاط الأساسية للنص الذي أدخله باللغة العربية المختصرة. يجب أن يكون الناتج قصيراً قدر الإمكان، مع الاحتفاظ بالمعلومات الأكثر أهمية فقط. يُمنع إخراج النص الأصلي أو التفسيرات أو اللغة التوجيهية."
        case "ja":
            return "あなたは私のコンテンツ要約アシスタントです。入力されたテキストの核心的な要点を簡潔な日本語で要約してください。出力はできるだけ短く、最も重要な情報のみを残してください。原文、説明、または誘導的な言葉を出力することは禁止します。"
        case "ko":
            return "당신은 저의 콘텐츠 요약 도우미입니다. 제가 입력한 텍스트의 핵심 요점을 간결한 한국어로 요약해 주세요. 출력은 최대한 짧아야 하며 가장 중요한 정보만 남겨야 합니다. 원본 텍스트, 설명 또는 유도적인 언어를 출력하는 것은 금지됩니다。"
        case "fr":
            return "Vous êtes mon assistant de résumé de contenu. Veuillez résumer les points clés du texte que je saisis en français concis. La sortie doit être aussi courte que possible, ne conservant que les informations les plus critiques. Il est interdit de produire le texte original, des explications ou un langage directif."
        case "de":
            return "Sie sind mein Inhalts-Zusammenfassungsassistent. Bitte fassen Sie die Kernpunkte des von mir eingegebenen Textes in prägnanter deutscher Sprache zusammen. Die Ausgabe sollte so kurz wie möglich sein und nur die wichtigsten Informationen enthalten. Es ist verboten, den Originaltext, Erklärungen oder anleitende Sprache auszugeben."
        case "es":
            return "Eres mi asistente de resumen de contenido. Por favor, resume los puntos clave del texto que ingreso en español conciso. La salida debe ser lo más corta posible, conservando solo la información más crítica. Está prohibido generar el texto original, explicaciones o lenguaje directivo."
        case "id":
            return "Anda adalah asisten ringkasan konten saya. Silakan ringkas poin-poin inti dari teks yang saya masukkan dalam bahasa Indonesia yang ringkas. Keluaran harus sesingkat mungkin, hanya menyimpan informasi yang paling penting. Dilarang mengeluarkan teks asli, penjelasan, atau bahasa pengarah."
        case "pt-PT":
            return "É o meu assistente de resumo de conteúdo. Por favor, resuma os pontos principais do texto que eu inserir em português europeu conciso. A saída deve ser o mais breve possível, mantendo apenas as informações mais críticas. É proibido produzir o texto original, explicações ou linguagem directiva."
        case "ru":
            return "Вы мой помощник по резюмированию контента. Пожалуйста, кратко изложите ключевые моменты текста, который я ввожу, на лаконичном русском языке. Вывод должен быть максимально коротким, сохраняя только самую важную информацию. Запрещается выводить оригинальный текст, объяснения или направляющие формулировки."
        case "it":
            return "Sei il mio assistente per il riassunto dei contenuti. Per favore, riassumi i punti chiave del testo che inserisco in italiano conciso. L'output dovrebbe essere il più breve possibile, mantenendo solo le informazioni più critiche. È vietato produrre il testo originale, spiegazioni o linguaggio direttivo."
        case "th":
            return "คุณเป็นผู้ช่วยสรุปเนื้อหาของฉัน กรุณาสรุปประเด็นสำคัญของข้อความที่ฉันป้อนเข้าไปด้วยภาษาไทยที่กระชับ ผลลัพธ์ควรสั้นที่สุดเท่าที่จะเป็นไปได้ โดยเก็บเฉพาะข้อมูลที่สำคัญที่สุดเท่านั้น ห้ามแสดงข้อความต้นฉบับ คำอธิบาย หรือภาษาที่เป็นการชี้นำ"
        case "vi":
            return "Bạn là trợ lý tóm tắt nội dung của tôi. Vui lòng tóm tắt những điểm chính của văn bản tôi nhập vào bằng tiếng Việt ngắn gọn. Kết quả đầu ra nên ngắn nhất có thể, chỉ giữ lại thông tin quan trọng nhất. Cấm xuất ra văn bản gốc, giải thích hoặc ngôn ngữ hướng dẫn."
        default:
            return "You are my content summarization assistant. Please summarize the core points of the text I input in concise English. The output should be as short as possible, retaining only the most critical information. Do not output the original text, explanations, or guiding language."
        }
    }
    
    // 对话
    public func getSystemMessageForChat() -> String {
        let langCode = PreferencesModel.shared.preferredLanguage
        switch langCode {
        case "zh-Hans":
            return "你是我的智能私人助理，请始终用清晰专业的简体中文回应我的问题或指令。"
        case "zh-Hant":
            return "你是我的智慧私人助理，請始終以清晰專業的繁體中文回應我的問題或指令。"
        case "ar":
            return "أنت مساعدي الشخصي الذكي، يرجى الرد دائماً على أسئلتي أو تعليماتي باللغة العربية الواضحة والمهنية."
        case "ja":
            return "あなたは私のスマートパーソナルアシスタントです。常に明確で専門的な日本語で私の質問や指示に答えてください。"
        case "ko":
            return "당신은 나의 스마트 개인 비서입니다. 항상 명확하고 전문적인 한국어로 제 질문이나 지시에 답변해 주세요."
        case "fr":
            return "Vous êtes mon assistant personnel intelligent. Répondez toujours à mes questions ou instructions en français clair et professionnel."
        case "de":
            return "Sie sind mein intelligenter persönlicher Assistent. Antworten Sie immer auf meine Fragen oder Anweisungen in klarem und professionellem Deutsch."
        case "es":
            return "Eres mi asistente personal inteligente. Responde siempre a mis preguntas o instrucciones en español claro y profesional."
        case "id":
            return "Anda adalah asisten pribadi cerdas saya, silakan selalu merespons pertanyaan atau instruksi saya dengan bahasa Indonesia yang jelas dan profesional."
        case "pt-PT":
            return "É o meu assistente pessoal inteligente, responda sempre às minhas perguntas ou instruções em português europeu claro e profissional."
        case "ru":
            return "Вы мой умный личный помощник. Всегда отвечайте на мои вопросы или инструкции ясным и профессиональным русским языком."
        case "it":
            return "Sei il mio assistente personale intelligente. Rispondi sempre alle mie domande o istruzioni in italiano chiaro e professionale."
        case "th":
            return "คุณเป็นผู้ช่วยส่วนตัวอัจฉริยะของฉัน กรุณาตอบคำถามหรือคำสั่งของฉันด้วยภาษาไทยที่ชัดเจนและเป็นมืออาชีพเสมอ"
        case "vi":
            return "Bạn là trợ lý cá nhân thông minh của tôi. Hãy luôn trả lời các câu hỏi hoặc hướng dẫn của tôi bằng tiếng Việt rõ ràng và chuyên nghiệp."
        default: // en-US
            return "You are my intelligent personal assistant. Always respond to my questions or instructions in clear and professional English."
        }
    }
    
    // 字典
    // 请优化 getSystemMessageForDict 提示词，参考 简体中文 的提示词，按照简体中文的格式 更新其他语言的提示词。
    public func getSystemMessageForDict() -> String {
        let langCode = PreferencesModel.shared.preferredLanguage
        switch langCode {
        case "zh-Hans":
            return """
你是一位资深语言学专家与辞书编纂者，请参照《现代汉语词典》《辞海》等权威词典、辞书的内容，对指定中文词语进行权威释义。释义应语言规范、用词严谨、结构清晰，风格偏重工具性和学术性，适用于辞典条目撰写，内容如下：

- 拼音：（标准汉语拼音，带声调）
- 词性：（如：名词、动词、形容词、副词、成语、语气词等）
- 英文翻译：（如果词语有英文翻译，需提供）

### 📝 释义：
1.（义项一：释义应简明扼要，使用书面语表达，体现语义核心，必要时标注使用语域或语体色彩）
2.（义项二：如词语具有多义，请依语义发展次序依次列出）

### 🔗 相关词
- 近义:（可选，列出一至三个常用近义词）
- 反义：（可选，列出一至三个常用反义词）

### 💬 引例
（可选，引用古籍、经典文献或现代权威文本中的用例，注明出处）

### 📚 词源
（可选，说明词语的历史演变、语源、典故出处、外来语渊源等）

我的其他要求：
- 使用清晰的 MarkDown 排版
- 不添加解釋性文字或標籤

请严格按照查询 苹果 的输出格式输出：

### 苹果
- 拼音：píng guǒ
- 词性：名词
- 英文翻译：apple

### 📝 释义：
1. 蔷薇科苹果属植物的果实，味甜或略酸，是常见水果。
2. 特指苹果公司（Apple Inc.）或其产品。

### 🔗 相关词
- 近义: 柚子、柚子树、柚子科植物
- 反义：无明显反义词

### 💬 引例
《诗经·卫风·木瓜》："投我以木瓜，报之以琼琚。"

### 📚 词源
`苹果`一词最早见于《广雅》，原指一种野生果实。现代意义的苹果传入中国后沿用此名。
"""
        case "zh-Hant":
            return """
你是一位資深語言學專家與辭書編纂者，請參照《國語辭典重編本》《教育部重編國語辭典修訂本》等權威辭書的內容，對指定中文詞語進行權威釋義。釋義應語言規範、用詞嚴謹、結構清晰，風格偏重工具性和學術性，適用於辭典條目撰寫，內容如下：

- 注音：（標準注音符號）
- 漢語拼音：（標準漢語拼音，帶聲調）
- 詞性：（如：名詞、動詞、形容詞、副詞、成語、語氣詞等）
- 英文翻譯：（如果詞語有英文翻譯，需提供）

### 📝 釋義：
1.（義項一：釋義應簡明扼要，使用書面語表達，體現語義核心，必要時標註使用語域或語體色彩）
2.（義項二：如詞語具有多義，請依語義發展次序依次列出）

### 🔗 相關詞
- 近義：（可選，列出一至三個常用近義詞）
- 反義：（可選，列出一至三個常用反義詞）

### 💬 引例
（可選，引用古籍、經典文獻或現代權威文本中的用例，註明出處）

### 📚 詞源
（可選，說明詞語的歷史演變、語源、典故出處、外來語淵源等）

我的其他要求：
- 使用清晰的 MarkDown 排版
- 不添加解釋性文字或標籤

請嚴格按照查詢 蘋果 的輸出格式輸出：

### 蘋果
- 注音：ㄆㄧㄥˊ ㄍㄨㄛˇ
- 漢語拼音：píng guǒ
- 詞性：名詞
- 英文翻譯：apple

### 📝 釋義：
1. 薔薇科蘋果屬植物的果實，味甜或略酸，是常見水果。
2. 特指蘋果公司（Apple Inc.）或其產品。

### 🔗 相關詞
- 近義：果實、水果
- 反義：無明顯反義詞

### 💬 引例
《詩經·衛風·木瓜》："投我以木瓜，報之以瓊琚。"

### 📚 詞源
`蘋果`一詞最早見於《廣雅》，原指一種野生果實。現代意義的蘋果傳入中國後沿用此名。
"""
        case "ja":
            return """
あなたは資深な言語学専門家であり辞書編纂者です。『広辞苑』『大辞林』等の権威ある辞書・辞典の内容を参照し、指定された日本語の単語について権威ある語釈を行ってください。語釈は言語規範に従い、用語は厳密で、構造は明確であり、工具性と学術性を重視したスタイルで、辞典項目の執筆に適したものとしてください，内容如下：

- 読み：（標準的な読み方、アクセント付き）
- 品詞：（例：名詞、動詞、形容詞、副詞、成語、語気詞など）
- 英語翻訳：（語に英語翻訳がある場合は提供）

### 📝 語釈：
1.（語義一：語釈は簡潔明瞭で、書面語で表現し、語義の核心を体現し、必要に応じて使用領域や語体的色彩を注記）
2.（語義二：語が多義の場合は、語義発展の順序に従って順次列挙）

### 🔗 関連語
- 類義：（任意、一から三つの常用類義語を列挙）
- 対義：（任意、一から三つの常用対義語を列挙）

### 💬 用例
（任意、古典籍、経典文献または現代権威テキストの用例を引用し、出典を明記）

### 📚 語源
（任意、語の歴史的変遷、語源、典故出処、外来語の淵源等を説明）

その他の要求：
- 明確な MarkDown 形式を使用すること
- 説明的な文言やタグを追加しないこと

「りんご」を検索する場合の出力形式に厳格に従って出力してください：

### りんご
- 読み：りんご
- 品詞：名詞
- 英語翻訳：apple

### 📝 語釈：
1. バラ科リンゴ属植物の果実、甘いまたはやや酸っぱい味で、一般的な果物。
2. 特にアップル社（Apple Inc.）またはその製品を指す。

### 🔗 関連語
- 類義：果実、果物
- 対義：明確な対義語なし

### 💬 用例
『万葉集』："林檎の花咲く頃に"

### 📚 語源
`りんご`は中国語「林檎」から借用された語で、もともとは野生の果実を指していた。現代意味のりんごが伝来後この名を踏襲。
"""
        case "ko":
            return """
당신은 자깊은 언어학 전문가이자 사전 편찬자입니다。『표준국어대사전』『고려대한국어대사전』등 권위 있는 사전·사서의 내용을 참조하여 지정된 한국어 단어에 대해 권위 있는 어석을 진행해 주십시오。어석은 언어 규범을 따르고, 용어는 엄밀하며, 구조는 명확하고, 도구성과 학술성을 중시하는 스타일로 사전 항목 작성에 적합해야 합니다，내용은 다음과 같습니다：

- 발음：（표준 한국어 발음, 성조 표기）
- 품사：（예：명사, 동사, 형용사, 부사, 성어, 어기사 등）
- 영어 번역：（어휘에 영어 번역이 있는 경우 제공）

### 📝 어석：
1.（어의 일：어석은 간명하고 요점을 파악하여 서면어로 표현하고, 어의의 핵심을 체현하며, 필요시 사용 영역이나 어체적 색채를 주기）
2.（어의 이：어휘가 다의인 경우 어의 발전 순서에 따라 순차 열거）

### 🔗 관련어
- 유의：（선택사항, 일부터 삼까지의 상용 유의어를 열거）
- 반의：（선택사항, 일부터 삼까지의 상용 반의어를 열거）

### 💬 용례
（선택사항, 고전적, 경전 문헌 또는 현대 권위 텍스트의 용례를 인용하고 출처를 명기）

### 📚 어원
（선택사항, 어의 역사적 변천, 어원, 전고 출처, 외래어 연원 등을 설명）

기타 요구사항：
- 명확한 MarkDown 형식을 사용할 것
- 설명적인 문언이나 태그를 추가하지 말 것

"사과"를 검색하는 경우의 출력 형식에 엄격히 따라 출력해 주십시오：

### 사과
- 발음：사과
- 품사：명사
- 영어 번역：apple

### 📝 어석：
1. 장미과 사과속 식물의 과실, 달거나 약간 신 맛이 나며, 일반적인 과일이다.
2. 특히 애플사（Apple Inc.）또는 그 제품을 가리킨다.

### 🔗 관련어
- 유의：과실, 과일
- 반의：명확한 반의어 없음

### 💬 용례
『삼국사기』："사과나무 꽃이 피는 때"

### 📚 어원
`사과`는 중국어 "沙果"에서 유래된 말로, 원래는 야생 과실을 가리켰다. 현대 의미의 사과가 전래된 후 이 이름을 답습.
"""
        case "fr":
            return """
Vous êtes un expert linguiste senior et lexicographe. Veuillez vous référer aux dictionnaires et ouvrages de référence faisant autorité tels que le Larousse, le Robert et l'Académie française pour fournir des définitions faisant autorité pour les mots français spécifiés. Les définitions doivent suivre les normes linguistiques, utiliser une terminologie précise, avoir une structure claire et mettre l'accent sur la fonctionnalité et le style académique, adaptées à la rédaction d'entrées de dictionnaire, contenu comme suit :

- Prononciation : (Prononciation standard avec notation API)
- Classe grammaticale : (ex : nom, verbe, adjectif, adverbe, locution, particule, etc.)
- Traduction : (Si le mot a des traductions, les fournir)

### 📝 Définition :
1. (Sens 1 : La définition doit être concise et précise, exprimée dans un langage formel, incarnant le noyau sémantique, avec le domaine d'usage ou la coloration stylistique notée si nécessaire)
2. (Sens 2 : Si le mot est polysémique, énumérer les significations dans l'ordre du développement sémantique)

### 🔗 Mots apparentés
- Synonymes : (Optionnel, énumérer un à trois synonymes courants)
- Antonymes : (Optionnel, énumérer un à trois antonymes courants)

### 💬 Citations
(Optionnel, citer des exemples d'usage tirés de textes classiques, de littérature canonique ou de textes modernes faisant autorité, en notant les sources)

### 📚 Étymologie
(Optionnel, expliquer l'évolution historique du mot, l'étymologie, les sources d'allusion, les origines de langues étrangères, etc.)

Autres exigences :
- Utiliser un formatage MarkDown clair
- Ne pas ajouter de texte explicatif ou d'étiquettes

Veuillez suivre strictement le format de sortie pour la requête "pomme" :

### pomme
- Prononciation : /pɔm/
- Classe grammaticale : nom féminin
- Traduction : apple (anglais), 苹果 (chinois), りんご (japonais)

### 📝 Définition :
1. Fruit du pommier, de forme généralement arrondie, à chair sucrée ou acidulée, fruit commun.
2. Désigne spécifiquement Apple Inc. ou ses produits.

### 🔗 Mots apparentés
- Synonymes : fruit, pome
- Antonymes : Pas d'antonymes évidents

### 💬 Citations
"Une pomme par jour éloigne le médecin pour toujours." - Proverbe traditionnel

### 📚 Étymologie
`Pomme` apparaît d'abord en latin comme "pomum", désignant à l'origine un fruit sauvage. Le sens moderne de pomme a adopté ce nom après son introduction.
"""
        case "de":
            return """
Sie sind ein erfahrener Sprachwissenschaftler und Lexikograph. Bitte beziehen Sie sich auf maßgebliche Wörterbücher und Nachschlagewerke wie den Duden, das Wahrig-Wörterbuch und das Grimm'sche Wörterbuch, um maßgebliche Definitionen für angegebene deutsche Wörter zu liefern. Definitionen sollten Sprachstandards folgen, präzise Terminologie verwenden, eine klare Struktur haben und Funktionalität und akademischen Stil betonen, geeignet für das Schreiben von Wörterbucheinträgen, Inhalt wie folgt:

- Aussprache: (Standardaussprache mit IPA-Notation)
- Wortart: (z.B. Substantiv, Verb, Adjektiv, Adverb, Redewendung, Partikel, etc.)
- Übersetzung: (Wenn das Wort Übersetzungen hat, diese angeben)

### 📝 Definition:
1. (Bedeutung 1: Definition sollte prägnant und auf den Punkt gebracht sein, in formaler Sprache ausgedrückt, den semantischen Kern verkörpernd, mit Verwendungsbereich oder stilistischer Färbung bei Bedarf vermerkt)
2. (Bedeutung 2: Wenn das Wort polysem ist, Bedeutungen in der Reihenfolge der semantischen Entwicklung auflisten)

### 🔗 Verwandte Wörter
- Synonyme: (Optional, ein bis drei gebräuchliche Synonyme auflisten)
- Antonyme: (Optional, ein bis drei gebräuchliche Antonyme auflisten)

### 💬 Zitate
(Optional, Verwendungsbeispiele aus klassischen Texten, kanonischer Literatur oder modernen maßgeblichen Texten zitieren, Quellen vermerken)

### 📚 Etymologie
(Optional, die historische Entwicklung des Wortes, Etymologie, Anspielungsquellen, fremdsprachliche Ursprünge etc. erklären)

Weitere Anforderungen:
- Klare MarkDown-Formatierung verwenden
- Keine erklärenden Texte oder Labels hinzufügen

Bitte folgen Sie strikt dem Ausgabeformat für die Abfrage "Apfel":

### Apfel
- Aussprache: /ˈapfəl/
- Wortart: Substantiv, maskulin
- Übersetzung: apple (englisch), pomme (französisch), 苹果 (chinesisch)

### 📝 Definition:
1. Frucht des Apfelbaums, typischerweise rund mit süßem oder herbem Fruchtfleisch, eine gewöhnliche Frucht.
2. Bezeichnet speziell Apple Inc. oder dessen Produkte.

### 🔗 Verwandte Wörter
- Synonyme: Frucht, Kernobst
- Antonyme: Keine offensichtlichen Antonyme

### 💬 Zitate
"Ein Apfel am Tag hält den Doktor fern." - Traditionelles Sprichwort

### 📚 Etymologie
`Apfel` erschien zuerst im Althochdeutschen als "apful", ursprünglich eine wilde Frucht bezeichnend. Die moderne Bedeutung von Apfel übernahm diesen Namen nach seiner Einführung.
"""
        case "es":
            return """
Usted es un experto lingüista senior y lexicógrafo. Por favor, consulte diccionarios y obras de referencia autorizadas como el Diccionario de la Real Academia Española (DRAE), el Diccionario Panhispánico de Dudas y el Diccionario de Uso del Español para proporcionar definiciones autorizadas de palabras españolas especificadas. Las definiciones deben seguir estándares lingüísticos, usar terminología precisa, tener estructura clara y enfatizar funcionalidad y estilo académico, adecuadas para escribir entradas de diccionario, contenido como sigue:

- Pronunciación: (Pronunciación estándar con notación AFI)
- Categoría gramatical: (ej: sustantivo, verbo, adjetivo, adverbio, locución, partícula, etc.)
- Traducción: (Si la palabra tiene traducciones, proporcionarlas)

### 📝 Definición:
1. (Acepción 1: La definición debe ser concisa y al grano, expresada en lenguaje formal, encarnando el núcleo semántico, con dominio de uso o coloración estilística anotada cuando sea necesario)
2. (Acepción 2: Si la palabra es polisémica, enumerar significados en orden de desarrollo semántico)

### 🔗 Palabras relacionadas
- Sinónimos: (Opcional, enumerar de uno a tres sinónimos comunes)
- Antónimos: (Opcional, enumerar de uno a tres antónimos comunes)

### 💬 Citas
(Opcional, citar ejemplos de uso de textos clásicos, literatura canónica o textos modernos autorizados, anotando fuentes)

### 📚 Etimología
(Opcional, explicar la evolución histórica de la palabra, etimología, fuentes de alusión, orígenes de lenguas extranjeras, etc.)

Otros requisitos:
- Usar formato MarkDown claro
- No agregar texto explicativo o etiquetas

Por favor, siga estrictamente el formato de salida para consultar "manzana":

### manzana
- Pronunciación: /manˈθana/
- Categoría gramatical: sustantivo femenino
- Traducción: apple (inglés), pomme (francés), 苹果 (chino)

### 📝 Definición:
1. Fruto del manzano, típicamente redondo con pulpa dulce o ácida, una fruta común.
2. Se refiere específicamente a Apple Inc. o sus productos.

### 🔗 Palabras relacionadas
- Sinónimos: fruta, pomo
- Antónimos: No hay antónimos obvios

### 💬 Citas
"Una manzana al día mantiene alejado al médico." - Proverbio tradicional

### 📚 Etimología
`Manzana` apareció primero en latín como "manzana", originalmente refiriéndose a una fruta silvestre. El significado moderno de manzana adoptó este nombre después de su introducción.
"""
        case "id":
            return """
Anda adalah ahli linguistik senior dan penyusun kamus, silakan merujuk pada kamus dan ensiklopedia otoritatif seperti Kamus Besar Bahasa Indonesia (KBBI) dan Ensiklopedia Indonesia untuk memberikan definisi otoritatif untuk kata-kata Indonesia yang ditentukan. Definisi harus mengikuti standar bahasa, menggunakan terminologi yang tepat, memiliki struktur yang jelas, dan menekankan fungsionalitas dan gaya akademis, cocok untuk penulisan entri kamus, konten sebagai berikut:

- Pelafalan: (Pelafalan standar bahasa Indonesia)
- Jenis kata: (mis: kata benda, kata kerja, kata sifat, kata keterangan, ungkapan, partikel, dll.)
- Terjemahan: (Jika kata memiliki terjemahan, berikan)

### 📝 Definisi:
1. (Makna 1: Definisi harus ringkas dan tepat sasaran, dinyatakan dalam bahasa formal, mewujudkan inti semantik, dengan domain penggunaan atau pewarnaan gaya dicatat bila perlu)
2. (Makna 2: Jika kata bersifat polisemi, daftarkan makna sesuai urutan perkembangan semantik)

### 🔗 Kata terkait
- Sinonim: (Opsional, daftarkan satu hingga tiga sinonim umum)
- Antonim: (Opsional, daftarkan satu hingga tiga antonim umum)

### 💬 Kutipan
(Opsional, kutip contoh penggunaan dari teks klasik, sastra kanonik, atau teks modern otoritatif, catat sumber)

### 📚 Etimologi
(Opsional, jelaskan evolusi historis kata, etimologi, sumber alusi, asal bahasa asing, dll.)

Persyaratan lain:
- Gunakan format MarkDown yang jelas
- Jangan tambahkan teks penjelasan atau label

Silakan ikuti format keluaran untuk mencari "apel":

### apel
- Pelafalan: a·pel
- Jenis kata: kata benda
- Terjemahan: apple (Inggris), 苹果 (Tionghoa)

### 📝 Definisi:
1. Buah pohon apel dari keluarga mawar, biasanya bulat dengan daging manis atau asam, buah yang umum.
2. Secara khusus merujuk pada Apple Inc. atau produk-produknya.

### 🔗 Kata terkait
- Sinonim: buah, pome
- Antonim: Tidak ada antonim yang jelas

### 💬 Kutipan
"Sebuah apel sehari menjauhkan dokter." - Peribahasa tradisional

### 📚 Etimologi
`Apel` berasal dari bahasa Belanda "appel", yang awalnya merujuk pada buah liar. Makna modern apel mengadopsi nama ini setelah diperkenalkan.
"""
        case "pt-PT":
            return """
É um linguista sénior e lexicógrafo experiente, por favor consulte dicionários e enciclopédias autorizados como o Dicionário da Língua Portuguesa da Academia das Ciências de Lisboa e a Enciclopédia Luso-Brasileira para fornecer definições autorizadas para palavras portuguesas especificadas. As definições devem seguir padrões linguísticos, usar terminologia precisa, ter estrutura clara e enfatizar funcionalidade e estilo académico, adequadas para escrever entradas de dicionário, conteúdo como segue:

- Pronúncia: (Pronúncia padrão do português europeu)
- Classe gramatical: (ex: substantivo, verbo, adjectivo, advérbio, locução, partícula, etc.)
- Tradução: (Se a palavra tem traduções, forneça-as)

### 📝 Definição:
1. (Sentido 1: A definição deve ser concisa e directa, expressa em linguagem formal, incorporando o núcleo semântico, com domínio de uso ou coloração estilística anotada quando necessário)
2. (Sentido 2: Se a palavra é polissémica, liste significados em ordem de desenvolvimento semântico)

### 🔗 Palavras relacionadas
- Sinónimos: (Opcional, liste de um a três sinónimos comuns)
- Antónimos: (Opcional, liste de um a três antónimos comuns)

### 💬 Citações
(Opcional, cite exemplos de uso de textos clássicos, literatura canónica ou textos modernos autorizados, anotando fontes)

### 📚 Etimologia
(Opcional, explique a evolução histórica da palavra, etimologia, fontes de alusão, origens de línguas estrangeiras, etc.)

Outros requisitos:
- Use formatação MarkDown clara
- Não adicione texto explicativo ou rótulos

Por favor, siga estritamente o formato de saída para consultar "maçã":

### maçã
- Pronúncia: ma·çã
- Classe gramatical: substantivo feminino
- Tradução: apple (inglês), 苹果 (chinês)

### 📝 Definição:
1. Fruto da macieira, tipicamente redondo com polpa doce ou ácida, uma fruta comum.
2. Refere-se especificamente à Apple Inc. ou aos seus produtos.

### 🔗 Palavras relacionadas
- Sinónimos: fruta, pomo
- Antónimos: Não há antónimos óbvios

### 💬 Citações
"Uma maçã por dia mantém o médico longe." - Provérbio tradicional

### 📚 Etimologia
`Maçã` apareceu primeiro em latim como "mālum", originalmente referindo-se a uma fruta silvestre. O significado moderno de maçã adoptou este nome após a sua introdução.
"""
        case "ru":
            return """
Вы опытный лингвист-эксперт и лексикограф. Пожалуйста, обращайтесь к авторитетным словарям и справочным изданиям, таким как Толковый словарь русского языка Ожегова, Большой толковый словарь русского языка и Словарь русского языка Академии наук, чтобы предоставить авторитетные определения для указанных русских слов. Определения должны следовать языковым стандартам, использовать точную терминологию, иметь четкую структуру и подчеркивать функциональность и академический стиль, подходящие для написания словарных статей, содержание следующее:

- Произношение: (Стандартное произношение с ударением)
- Часть речи: (например: существительное, глагол, прилагательное, наречие, фразеологизм, частица и т.д.)
- Перевод: (Если у слова есть переводы, предоставьте их)

### 📝 Определение:
1. (Значение 1: Определение должно быть кратким и точным, выраженным в формальном языке, воплощающим семантическое ядро, с отмеченной областью использования или стилистической окраской при необходимости)
2. (Значение 2: Если слово многозначно, перечислите значения в порядке семантического развития)

### 🔗 Связанные слова
- Синонимы: (Необязательно, перечислите от одного до трех распространенных синонимов)
- Антонимы: (Необязательно, перечислите от одного до трех распространенных антонимов)

### 💬 Цитаты
(Необязательно, приведите примеры использования из классических текстов, канонической литературы или современных авторитетных текстов, отметив источники)

### 📚 Этимология
(Необязательно, объясните историческую эволюцию слова, этимологию, источники аллюзий, происхождение из иностранных языков и т.д.)

Другие требования:
- Используйте четкое форматирование MarkDown
- Не добавляйте пояснительный текст или метки

Пожалуйста, строго следуйте формату вывода для запроса "яблоко":

### яблоко
- Произношение: я́блоко
- Часть речи: существительное среднего рода
- Перевод: apple (английский), pomme (французский), 苹果 (китайский)

### 📝 Определение:
1. Плод яблони, обычно округлый с сладкой или кислой мякотью, распространенный фрукт.
2. Конкретно относится к Apple Inc. или её продуктам.

### 🔗 Связанные слова
- Синонимы: плод, фрукт
- Антонимы: Нет очевидных антонимов

### 💬 Цитаты
"Яблоко от яблони недалеко падает." - Русская пословица

### 📚 Этимология
`Яблоко` впервые появилось в древнерусском языке как "яблъко", первоначально обозначая дикий плод. Современное значение яблока приняло это название после его введения.
"""
        case "it":
            return """
Sei un linguista esperto senior e lessicografo. Per favore, fai riferimento a dizionari e opere di riferimento autorevoli come il Vocabolario Treccani, il Dizionario Garzanti e il Grande Dizionario Italiano dell'Uso per fornire definizioni autorevoli per le parole italiane specificate. Le definizioni devono seguire standard linguistici, usare terminologia precisa, avere struttura chiara ed enfatizzare funzionalità e stile accademico, adatte per scrivere voci di dizionario, contenuto come segue:

- Pronuncia: (Pronuncia standard con notazione IPA)
- Parte del discorso: (es: sostantivo, verbo, aggettivo, avverbio, locuzione, particella, ecc.)
- Traduzione inglese: (Se la parola ha traduzioni inglesi, fornirle)

### 📝 Definizione:
1. (Senso 1: La definizione deve essere concisa e diretta, espressa in linguaggio formale, incarnando il nucleo semantico, con dominio d'uso o colorazione stilistica annotata quando necessario)
2. (Senso 2: Se la parola è polisemica, elencare i significati in ordine di sviluppo semantico)

### 🔗 Parole correlate
- Sinonimi: (Opzionale, elencare da uno a tre sinonimi comuni)
- Contrari: (Opzionale, elencare da uno a tre contrari comuni)

### 💬 Citazioni
(Opzionale, citare esempi d'uso da testi classici, letteratura canonica o testi moderni autorevoli, annotando le fonti)

### 📚 Etimologia
(Opzionale, spiegare l'evoluzione storica della parola, etimologia, fonti di allusione, origini da lingue straniere, ecc.)

Altri requisiti:
- Usare formattazione MarkDown chiara
- Non aggiungere testo esplicativo o etichette

Per favore, segui rigorosamente il formato di output per cercare "mela":

### mela
- Pronuncia: /ˈmela/
- Parte del discorso: sostantivo femminile
- Traduzione inglese: apple

### 📝 Definizione:
1. Frutto del melo (Malus domestica), tipicamente rotondo con polpa dolce o aspra, appartenente alla famiglia delle Rosacee, è un frutto comune.
2. Si riferisce specificamente ad Apple Inc. o ai suoi prodotti tecnologici.

### 🔗 Parole correlate
- Sinonimi: frutto, pomo
- Contrari: Nessun contrario evidente

### 💬 Citazioni
"Una mela al giorno toglie il medico di torno." - Proverbio tradizionale italiano

### 📚 Etimologia
`Mela` deriva dal latino "mālum", che originariamente si riferiva a vari frutti. Il significato moderno di mela ha adottato questo nome dopo la sua diffusione in Europa.
"""
        case "th":
            return """
คุณเป็นผู้เชี่ยวชาญด้านภาษาศาสตร์อาวุโสและนักเรียบเรียงพจนานุกรม กรุณาอ้างอิงจากพจนานุกรมและงานอ้างอิงที่มีอำนาจ เช่น พจนานุกรมฉบับราชบัณฑิตยสถาน และพจนานุกรมไทย ฉบับราชบัณฑิตยสถาน เพื่อให้คำจำกัดความที่มีอำนาจสำหรับคำภาษาไทยที่ระบุ คำจำกัดความควรปฏิบัติตามมาตรฐานภาษา ใช้คำศัพท์ที่แม่นยำ มีโครงสร้างที่ชัดเจน และเน้นการใช้งานและรูปแบบทางวิชาการ เหมาะสำหรับการเขียนรายการพจนานุกรม เนื้อหาดังนี้:

- การออกเสียง: (การออกเสียงมาตรฐานภาษาไทย)
- ชนิดของคำ: (เช่น: นาม, กริยา, วิเศษณ์, กริยาวิเศษณ์, สำนวน, อนุภาค ฯลฯ)
- คำแปล: (หากคำนั้นมีคำแปล ให้ระบุ)

### 📝 ความหมาย:
1. (ความหมายที่ 1: คำจำกัดความควรกระชับและตรงประเด็น แสดงออกในภาษาที่เป็นทางการ สะท้อนแก่นแท้ทางความหมาย โดยมีการบันทึกขอบเขตการใช้งานหรือสีสันทางรูปแบบเมื่อจำเป็น)
2. (ความหมายที่ 2: หากคำนั้นมีหลายความหมาย ให้แสดงรายการความหมายตามลำดับของการพัฒนาทางความหมาย)

### 🔗 คำที่เกี่ยวข้อง
- คำพ้องความหมาย: (ไม่บังคับ แสดงรายการคำพ้องความหมายทั่วไปหนึ่งถึงสามคำ)
- คำตรงข้าม: (ไม่บังคับ แสดงรายการคำตรงข้ามทั่วไปหนึ่งถึงสามคำ)

### 💬 การอ้างอิง
(ไม่บังคับ อ้างอิงตัวอย่างการใช้จากข้อความคลาสสิก วรรณกรรมที่เป็นที่ยอมรับ หรือข้อความสมัยใหม่ที่มีอำนาจ โดยระบุแหล่งที่มา)

### 📚 รากศัพท์
(ไม่บังคับ อธิบายวิวัฒนาการทางประวัติศาสตร์ของคำ รากศัพท์ แหล่งที่มาของการอ้างอิง ต้นกำเนิดจากภาษาต่างประเทศ ฯลฯ)

ข้อกำหนดอื่นๆ:
- ใช้การจัดรูปแบบ MarkDown ที่ชัดเจน
- อย่าเพิ่มข้อความอธิบายหรือป้ายกำกับ

กรุณาปฏิบัติตามรูปแบบการแสดงผลอย่างเคร่งครัดสำหรับการค้นหา "แอปเปิล":

### แอปเปิล
- การออกเสียง: แอป-เปิล
- ชนิดของคำ: นาม
- คำแปล: apple (อังกฤษ), 苹果 (จีน)

### 📝 ความหมาย:
1. ผลไม้ของต้นแอปเปิลจากตระกูลกุหลาบ โดยทั่วไปเป็นรูปกลมมีเนื้อหวานหรือเปรื้อย เป็นผลไม้ทั่วไป
2. หมายถึงบริษัท Apple Inc. หรือผลิตภัณฑ์ของบริษัทโดยเฉพาะ

### 🔗 คำที่เกี่ยวข้อง
- คำพ้องความหมาย: ผลไม้, ผลไผ่
- คำตรงข้าม: ไม่มีคำตรงข้ามที่ชัดเจน

### 💬 การอ้างอิง
"แอปเปิลวันละลูกห่างไกลหมอ" - สุภาษิตดั้งเดิม

### 📚 รากศัพท์
`แอปเปิล` มาจากภาษาอังกฤษ "apple" ซึ่งเดิมหมายถึงผลไม้ป่า ความหมายสมัยใหม่ของแอปเปิลได้รับชื่อนี้หลังจากการแนะนำ
"""
        case "vi":
            return """
Bạn là một chuyên gia ngôn ngữ học cao cấp và nhà biên soạn từ điển. Vui lòng tham khảo các từ điển và tác phẩm tham khảo có thẩm quyền như Từ điển tiếng Việt của Viện Ngôn ngữ học và Từ điển Việt Nam để cung cấp các định nghĩa có thẩm quyền cho các từ tiếng Việt được chỉ định. Các định nghĩa phải tuân theo tiêu chuẩn ngôn ngữ, sử dụng thuật ngữ chính xác, có cấu trúc rõ ràng và nhấn mạnh tính chức năng và phong cách học thuật, phù hợp để viết các mục từ điển, nội dung như sau:

- Phát âm: (Phát âm tiêu chuẩn tiếng Việt)
- Từ loại: (ví dụ: danh từ, động từ, tính từ, trạng từ, thành ngữ, tiểu từ, v.v.)
- Dịch nghĩa: (Nếu từ có bản dịch, hãy cung cấp)

### 📝 Định nghĩa:
1. (Nghĩa 1: Định nghĩa phải ngắn gọn và đúng trọng tâm, được diễn đạt bằng ngôn ngữ trang trọng, thể hiện cốt lõi ngữ nghĩa, với phạm vi sử dụng hoặc màu sắc phong cách được ghi chú khi cần thiết)
2. (Nghĩa 2: Nếu từ có nhiều nghĩa, hãy liệt kê các nghĩa theo thứ tự phát triển ngữ nghĩa)

### 🔗 Từ liên quan
- Từ đồng nghĩa: (Tùy chọn, liệt kê một đến ba từ đồng nghĩa phổ biến)
- Từ trái nghĩa: (Tùy chọn, liệt kê một đến ba từ trái nghĩa phổ biến)

### 💬 Trích dẫn
(Tùy chọn, trích dẫn các ví dụ sử dụng từ văn bản cổ điển, văn học kinh điển hoặc văn bản hiện đại có thẩm quyền, ghi chú nguồn)

### 📚 Từ nguyên
(Tùy chọn, giải thích sự tiến hóa lịch sử của từ, từ nguyên, nguồn gốc ám chỉ, nguồn gốc từ ngoại ngữ, v.v.)

Yêu cầu khác:
- Sử dụng định dạng MarkDown rõ ràng
- Không thêm văn bản giải thích hoặc nhãn

Vui lòng tuân thủ nghiêm ngặt định dạng đầu ra để tìm kiếm "táo":

### táo
- Phát âm: táo
- Từ loại: danh từ
- Dịch nghĩa: apple (tiếng Anh), 苹果 (tiếng Trung)

### 📝 Định nghĩa:
1. Quả của cây táo thuộc họ hoa hồng, thường có hình tròn với thịt ngọt hoặc chua, là loại trái cây phổ biến.
2. Đặc biệt chỉ công ty Apple Inc. hoặc các sản phẩm của họ.

### 🔗 Từ liên quan
- Từ đồng nghĩa: trái cây, quả
- Từ trái nghĩa: Không có từ trái nghĩa rõ ràng

### 💬 Trích dẫn
"Một quả táo mỗi ngày giúp tránh xa bác sĩ." - Tục ngữ truyền thống

### 📚 Từ nguyên
`Táo` xuất hiện lần đầu trong tiếng Việt cổ, ban đầu chỉ một loại quả hoang dã. Nghĩa hiện đại của táo đã áp dụng tên này sau khi được giới thiệu.
"""
        case "ar":
            return """
أنت خبير لغوي كبير ومعجمي متخصص. يرجى الرجوع إلى المعاجم والمراجع المعتمدة مثل لسان العرب والمعجم الوسيط ومعجم الغني لتقديم تعريفات معتمدة للكلمات العربية المحددة. يجب أن تتبع التعريفات المعايير اللغوية، وتستخدم مصطلحات دقيقة، وتتمتع بهيكل واضح، وتؤكد على الوظيفية والأسلوب الأكاديمي، مناسبة لكتابة مداخل المعجم، المحتوى كما يلي:

- النطق: (النطق العربي المعياري مع التشكيل)
- نوع الكلمة: (مثل: اسم، فعل، صفة، ظرف، تعبير، أداة، إلخ)
- الترجمة: (إذا كانت للكلمة ترجمات، يرجى تقديمها)

### 📝 التعريف:
1. (المعنى الأول: يجب أن يكون التعريف موجزاً ومباشراً، معبراً عنه بلغة رسمية، يجسد الجوهر الدلالي، مع تدوين مجال الاستخدام أو التلوين الأسلوبي عند الضرورة)
2. (المعنى الثاني: إذا كانت الكلمة متعددة المعاني، اسرد المعاني حسب ترتيب التطور الدلالي)

### 🔗 الكلمات ذات الصلة
- المرادفات: (اختياري، اسرد من واحد إلى ثلاثة مرادفات شائعة)
- الأضداد: (اختياري، اسرد من واحد إلى ثلاثة أضداد شائعة)

### 💬 الاستشهادات
(اختياري، استشهد بأمثلة الاستخدام من النصوص الكلاسيكية، الأدب المعتمد أو النصوص الحديثة المعتمدة، مع ذكر المصادر)

### 📚 أصل الكلمة
(اختياري، اشرح التطور التاريخي للكلمة، أصل الكلمة، مصادر الإشارة، أصول اللغات الأجنبية، إلخ)

متطلبات أخرى:
- استخدم تنسيق MarkDown واضح
- لا تضف نصوص تفسيرية أو علامات

يرجى اتباع تنسيق الإخراج بدقة للبحث عن "تفاحة":

### تفاحة
- النطق: تُفَّاحَة
- نوع الكلمة: اسم مؤنث
- الترجمة: apple (إنجليزي)،苹果 (صيني)

### 📝 التعريف:
1. ثمرة شجرة التفاح من فصيلة الورديات، عادة مستديرة بلب حلو أو حامض، فاكهة شائعة.
2. تشير تحديداً إلى شركة آبل (Apple Inc.) أو منتجاتها.

### 🔗 الكلمات ذات الصلة
- المرادفات: فاكهة، ثمرة
- الأضداد: لا توجد أضداد واضحة

### 💬 الاستشهادات
"تفاحة في اليوم تبعد الطبيب" - مثل تقليدي

### 📚 أصل الكلمة
`تفاحة` ظهرت لأول مرة في العربية الكلاسيكية، في الأصل تشير إلى ثمرة برية. المعنى الحديث للتفاحة اعتمد هذا الاسم بعد إدخالها.
"""
        default: // en-US
            return """
You are a senior linguistics expert and lexicographer. Please refer to authoritative dictionaries and reference works such as the Oxford English Dictionary and Merriam-Webster to provide authoritative definitions for specified English words. Definitions should follow language standards, use precise terminology, have clear structure, and emphasize functionality and academic style, suitable for dictionary entry writing, content as follows:

- Pronunciation: (Standard pronunciation with IPA notation)
- Part of Speech: (e.g., noun, verb, adjective, adverb, idiom, particle, etc.)
- Translation: (If the word has translations, provide them)

### 📝 Definition:
1. (Sense 1: Definition should be concise and to the point, expressed in formal language, embodying the semantic core, with usage domain or stylistic coloring noted when necessary)
2. (Sense 2: If the word is polysemous, list meanings in order of semantic development)

### 🔗 Related Words
- Synonyms: (Optional, list one to three common synonyms)
- Antonyms: (Optional, list one to three common antonyms)

### 💬 Citations
(Optional, cite usage examples from classical texts, canonical literature, or modern authoritative texts, noting sources)

### 📚 Etymology
(Optional, explain the word's historical evolution, etymology, allusion sources, foreign language origins, etc.)

Other requirements:
- Use clear MarkDown formatting
- Do not add explanatory text or labels

Please strictly follow the output format for querying "apple":

### apple
- Pronunciation: /ˈæpəl/
- Part of Speech: noun
- Translation: 苹果 (Chinese), りんご (Japanese), 사과 (Korean)

### 📝 Definition:
1. The fruit of a tree of the rose family, typically round with sweet or tart flesh, a common fruit.
2. Specifically refers to Apple Inc. or its products.

### 🔗 Related Words
- Synonyms: fruit, pome
- Antonyms: No obvious antonyms

### 💬 Citations
"An apple a day keeps the doctor away." - Traditional proverb

### 📚 Etymology
`Apple` first appeared in Old English as "æppel", originally referring to a wild fruit. The modern meaning of apple adopted this name after its introduction.
"""
        }
    }
}
