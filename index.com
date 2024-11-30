<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>武将検索</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <!-- メニューアイコン -->
    <div id="menu-toggle" class="menu-toggle">
        <div class="bar"></div>
        <div class="bar"></div>
        <div class="bar"></div>
    </div>

    <!-- メニューのコンテンツ（隠れるようにしておく）-->
    <div id="menu" class="menu">
        <ul>
            <li><a href="index.html" id="home">ホーム</a></li>
            <li><a href="#">武将一覧</a></li>
            <li><a href="#" id="toggleDarkMode">ダークモード</a></li>
        </ul>
    </div>

    <div class="container">
        <h1>武将検索</h1>
        <form id="searchForm">
            <input type="text" id="searchInput" placeholder="武将名またはスキル名、スキル内容で検索">
            <select id="countrySelect">
                <option value="">全ての国</option>
                <option value="秦">秦</option>
                <option value="趙">趙</option>
                <option value="魏">魏</option>
                <option value="楚">楚</option>
                <option value="韓">韓</option>
                <option value="斉">斉</option>
                <option value="燕">燕</option>
                <option value="毐">毐</option>
            </select>
            <button type="submit">検索</button>
        </form>

        <div class="search-summary">
            <p id="searchConditions"></p>
            <button id="resetFilters" class="hidden">フィルタを解除</button>
        </div>

        <div id="results" class="results">
            <!-- 検索結果がここに表示される -->
        </div>
    </div>

    <script>
        // ダークモード切り替えの処理
        const toggleDarkModeButton = document.getElementById('toggleDarkMode');

        toggleDarkModeButton.addEventListener('click', function() {
            document.body.classList.toggle('dark-mode'); // dark-modeクラスを切り替え
        });

        // メニューの開閉を制御する
        const menuToggle = document.getElementById('menu-toggle');
        const menu = document.getElementById('menu');

        // メニューアイコンクリック時にメニューの表示を切り替える
        menuToggle.addEventListener('click', function () {
            menu.classList.toggle('open'); // "open" クラスの切り替え
            menuToggle.classList.toggle('open'); // アイコンにも "open" クラスを追加してスタイル変更
        });

        // ホームリンクの処理
        document.getElementById('home').addEventListener('click', function() {
            window.scrollTo(0, 0); // ページトップに戻る
        });

        // 検索条件の表示エリアとフィルタ解除ボタン
        const searchConditions = document.getElementById('searchConditions');
        const resetFiltersButton = document.getElementById('resetFilters');

        // 初期状態で「検索条件が設定されていません。」を表示
        searchConditions.textContent = "検索条件が設定されていません。";

        // 検索フォームの要素を取得
        const searchForm = document.getElementById('searchForm');
        const searchInput = document.getElementById('searchInput');
        const countrySelect = document.getElementById('countrySelect');
        const resultsDiv = document.getElementById('results');

        // 武将データ
        const data = [
            {
                name: "那貴",
                reading: "なき",
                skills: [
                    "名将一閃【黄羊】〈戦技〉: 最大士気が最も高い敵武将1名に150%のダメージを与える。味方秦国武将の防御力が20%上昇（3ターン）する。",
                    "機先を制する〈軍略〉: 自身が「必中」状態になる。味方桓騎軍武将の防御力貫通が20%上昇する。侵攻時には、味方桓騎軍武将が「見切り（20%）」状態になる。",
                    "静かなる制圧〈戦技〉: 70%の確率で敵趙国、魏国武将に「体力回復無効」状態（4ターン）を付与する。侵攻時には、味方桓騎軍武将のクリティカル発生率が20%上昇（3ターン）する。最大士気が最も高い敵武将1名に180%のダメージを与える。"
                ],
                country: "秦"
            },
            {
                name: "我呂",
                reading: "がろ",
                skills: [
                    "攻撃強化【橙象】〈軍略〉: 自身以外の味方歩兵武将と騎兵武将の攻撃力が20%上昇する。",
                    "先手必勝〈戦技〉: 最大士気が最も高い敵武将1名に150%のダメージを与える。自身以外の味方歩兵武将と騎兵武将に攻撃無効（1回）を付与する。",
                    "戦乱巧者〈戦技〉: 残り体力が最も低い敵武将1名に170%のダメージを与える。自身以外の味方騎兵武将が生存している場合、味方全武将の攻撃力が10%上昇（4ターン）する。味方歩兵武将が生存している場合、味方全武将の防御力が10%上昇（4ターン）する。味方秦国武将に攻撃無効（1回）を付与する。"
                ],
                country: "秦"
            },
            {
                name:"岳雷",
                reading:"がくらい",
                skills:[
                    "防御強化【橙牛】〈軍略〉: 味方秦国武将の防御力が20%上昇する。侵攻時には、味方「麃公」、飛信隊武将の「裏切り」状態になる確率が20%低下する。",
                    "後手必勝〈戦技〉: 自身の残り体力が90%未満の場合、味方秦国武将のクリティカルダメージが20%上昇（3ターン）する。味方「麃公」・飛信隊武将の体力と土気を20%回復する。最大士気が最も高い敵武将1名に80%のダメージを3回与える。",
                    "乱戦強者〈戦技〉: 味方秦国武将のクリティカル発生率が10%上昇（3ターン）する。味方「麃公」、飛信隊武将のクリティカル発生率が20%上昇（3ターン）する。最大士気が最も高い敵武将1名に80%のダメージを4回与える。"
                ],
                country: "秦"
            }
        ];

        // 結果を表示する関数
        function displayResults(filteredData, query, country) {
            resultsDiv.innerHTML = ""; // 結果をリセット
            searchConditions.innerHTML = ""; //検索条件をリセット

            if (filteredData.length === 0) {
                resultsDiv.innerHTML = "<p>該当する武将が見つかりません。</p>";
            }
            
            // 検索条件を作成
            let conditionsText = "現在の検索条件: ";
            if (query) {
                conditionsText += `武将名またはスキル名/内容「${query}」 `;
            }
            if (country) {
                conditionsText += `国「${country}」`;
            }

            // 条件がない場合
            if (!query && !country) {
                conditionsText = "検索条件が設定されていません。";
            }

            // 検索条件を表示
            searchConditions.textContent = conditionsText;

            // 条件があればリセットボタンを表示
            if (query || country) {
                resetFiltersButton.classList.remove('hidden');
            } else {
                resetFiltersButton.classList.add('hidden');
            }

            //結果表示
            filteredData.forEach(item => {
                const resultItem = document.createElement('div');
                resultItem.classList.add('result-card');

                // フィルタリングされたスキル（インデックス保持）
                let filteredSkills = [];
                
                // 武将名が一致する場合、すべてのスキルを表示
                if (query !== "" && (item.name.includes(query) || item.reading.includes(query))) {
                    filteredSkills = item.skills.map((skill, index) => ({ skill, index }));
                } else if (query !== "") {
                    // スキル内容での検索
                    filteredSkills = item.skills
                        .map((skill, index) => ({ skill, index }))  // スキルとインデックスを保持
                        .filter(item => item.skill.includes(query)); // クエリに一致したスキルのみ
                } else {
                    // クエリが空の場合、すべてのスキルを表示
                    filteredSkills = item.skills.map((skill, index) => ({ skill, index }));
                }

                //スキルカードを生成
                let skillCards = "";
                filteredSkills.forEach(({ skill, index }) => {
                    // 正規表現で全角・半角コロンを検出して分割
                    const [skillName, skillDescription] = skill.split(/：|:/).map(str => str.trim());  // trimで余分なスペースを除去
                    skillCards += `
                        <div class="skill-card">
                            <h4>スキル${index + 1}：${skillName}</h4>
                            <p>${skillDescription}</p>
                        </div>
                    `;
                });

                resultItem.innerHTML = `
                    <h2>${item.name}</h2>
                    <div class="skills">
                        ${skillCards || "<p>該当するスキルが見つかりません。</p>"}
                    </div>
                `;
                resultsDiv.appendChild(resultItem);
            });
        }

        // 検索フォームの送信イベント
        searchForm.addEventListener('submit', function (event) {
            event.preventDefault(); // ページリロードを防止
        
            const query = searchInput.value.trim();
            const selectedCountry = countrySelect.value;
         
            const filteredData = data.filter(item => {
                const isNameMatch = query === "" || item.name.includes(query) || item.reading.includes(query);
                const isSkillMatch = query === "" || item.skills.some(skill => skill.includes(query));
                const isCountryMatch = selectedCountry === "" || item.country === selectedCountry;
                return (isNameMatch || isSkillMatch) && isCountryMatch;
            });
            
            displayResults(filteredData, query, selectedCountry);
        });

        // フィルタ解除ボタンの動作
        resetFiltersButton.addEventListener('click', () => {
            searchInput.value = "";
            countrySelect.value = "";
            searchConditions.textContent = "検索条件が設定されていません。";
            resetFiltersButton.classList.add('hidden');
            resultsDiv.innerHTML = ""; // 結果もリセット
        });
    </script>
</body>
</html>
