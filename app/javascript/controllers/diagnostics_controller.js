import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
// ターゲット定義：HTML要素とJSの紐付け
  static targets = [ 
    "card", "deck", "swipeSection", "mappingSection", "controls", 
    "plottedCards", "svg", "xSelect", "ySelect",
    "labelXMin", "labelXMax", "labelYMin", "labelYMax"
  ]
//値定義：RailsからジャンルIDを受け取る
  static values = { genreId: Number }

  connect() {
    this.currentIndex = 0 // 現在表示中のカードインデックス
    this.likedImages = [] // Likeした写真データを格納する配列
    this.labelMap = {
    // 軸ラベルのマップ定義
      'luxury_casual': ['親しみやすい', '高級感'],
      'natural_artificial': ['人工的', 'ナチュラル感'],
      'simple_detail': ['シンプル', 'ディテール'],
      'soft_solid': ['クール', '柔らかい・優しい'],
      'tradition_modern': ['先進的', '伝統的'],
      'chic_pop': ['ポップ', 'シック']
    }
    // キーボード操作のイベントリスナーの設定
    this.keydownHandler = this.handleKeydown.bind(this)
    window.addEventListener("keydown", this.keydownHandler)
    this.renderCard()
  }
  // 画面遷移時のイベントリスナーを解除して、メモリリークを防ぐ
  disconnect() {
    window.removeEventListener("keydown", this.keydownHandler)
  }
  // キーボード操作のハンドリング
  handleKeydown(event) {
    if (this.swipeSectionTarget.classList.contains("hidden")) return
    if (event.key === "ArrowRight") this.like()
    else if (event.key === "ArrowLeft") this.dislike()
  }
  // スワイプカードの表示・非表示の切り替え
  renderCard() {
    // 全てのカードをスワイプし終えたらマッピング画面へ遷移
    if (this.currentIndex >= this.cardTargets.length) {
      this.showMapping()
      return
    }

    this.cardTargets.forEach((card, index) => {
      const isCurrent = index === this.currentIndex
      card.classList.toggle("hidden", !isCurrent)
      if (isCurrent) {
        card.style.opacity = "1"
        card.style.pointerEvents = "auto"
        if (card.dataset.imageUrl) card.style.backgroundImage = `url(${card.dataset.imageUrl})`
      } else {
        card.style.opacity = "0"
        card.style.pointerEvents = "none"
      }
    })
  }
  
 // Likeアクション：サーバーへ通知し、ローカル配列に保存
  like() {
    const card = this.cardTargets[this.currentIndex]
    const photoId = card.dataset.id
    this._sendRequest('/likes', 'POST', { photo_id: photoId })
    this.likedImages.push({
      id: photoId,
      url: card.dataset.imageUrl,
      scores: JSON.parse(card.dataset.scores)
    })
    this.next()
  }

  // Dislikeアクション：サーバーへ通知（Like解除）
  dislike() {
    const card = this.cardTargets[this.currentIndex]
    this._sendRequest('/likes/destroy_by_photo', 'DELETE', { photo_id: card.dataset.id })
    this.next()
  }

  next() {
    this.currentIndex++
    this.renderCard()
  }

  // マッピング画面（分布図）の生成と表示
  showMapping() {
    this.swipeSectionTarget.classList.add("hidden")
    this.mappingSectionTarget.classList.remove("hidden")
    if (this.hasControlsTarget) this.controlsTarget.classList.remove("hidden")

    this.updatePositions()
  }
 // 軸の変更があった際に写真を再配置
  updatePositions() {
    const xKey = this.xSelectTarget.value
    const yKey = this.ySelectTarget.value
    this.updateLabels(xKey, yKey)

    this.plottedCardsTarget.innerHTML = ""
    const points = []

    // Likeした写真を分布図にプロット
    this.likedImages.forEach((img, index) => {
      const item = document.createElement("div")
      item.className = "plotted-item w-[70px] h-[90px] absolute bg-cover bg-center border-2 border-white shadow-lg transition-all duration-1000 ease-out"
      item.id = `plotted-${img.id}`
      item.style.backgroundImage = `url(${img.url})`
      
      const xPos = img.scores[xKey] || 50
      const yPos = img.scores[yKey] || 50
      
      item.style.left = "50%"
      item.style.top = "50%"
      
      this.plottedCardsTarget.appendChild(item)
   // 時間差で各スコアの位置へアニメーション移動
      setTimeout(() => {
        item.style.left = `${xPos}%`
        item.style.top = `${100 - yPos}%`
        item.style.transform = `translate(-50%, -50%) rotate(${Math.random() * 20 - 10}deg)`
      }, 50 + (index * 50))
      
      points.push({ x: xPos, y: 100 - yPos })
    })

  // 再配置後にサークル（クラスター）を再描画
    setTimeout(() => this.analyzeClusters(points), 1200)
  }

  // クラスター（密集地）を分析してサークルの位置を決定
  analyzeClusters(points) {
    if (points.length === 0) return
    this.svgTarget.innerHTML = ""

    const grid = Array.from({ length: 3 }, () => Array(4).fill(0))
    
    // グリッド（3x4）にポイントを割り当て
    points.forEach(p => {
      const col = Math.min(Math.floor(p.x / (100 / 3)), 2)
      const row = Math.min(Math.floor(p.y / (100 / 4)), 3)
      grid[col][row]++
    })

    let maxCount = 0
    let bestArea = { col: 1, row: 1 }
    
    // 最もポイントが密集しているエリアを探す
    for (let c = 0; c < 3; c++) {
      for (let r = 0; r < 4; r++) {
        if (grid[c][r] > maxCount) {
          maxCount = grid[c][r]
          bestArea = { col: c, row: r }
        }
      }
    }

    // 密集エリア内の平均座標を計算
    const areaPoints = points.filter(p => {
      const c = Math.min(Math.floor(p.x / (100 / 3)), 2)
      const r = Math.min(Math.floor(p.y / (100 / 4)), 3)
      return c === bestArea.col && r === bestArea.row
    })

    const avgX = areaPoints.reduce((sum, p) => sum + p.x, 0) / areaPoints.length
    const avgY = areaPoints.reduce((sum, p) => sum + p.y, 0) / areaPoints.length

    this.drawCircle(avgX, avgY)
  }

    // 密集エリアを示すサークルを描画
  drawCircle(cx, cy) {
    // SVG自体は背後の要素を触れるようにしつつ、中身の要素はイベントを受け取れるように設定
    this.svgTarget.style.pointerEvents = "none"

    const circle = document.createElementNS("http://www.w3.org/2000/svg", "circle")
    circle.setAttribute("cx", `${cx}%`)
    circle.setAttribute("cy", `${cy}%`)
    circle.setAttribute("r", "15%")
    circle.setAttribute("fill", "rgba(212, 163, 115, 0.4)")
    circle.setAttribute("stroke", "#d4a373")
    circle.setAttribute("stroke-width", "3")
    circle.setAttribute("stroke-dasharray", "5,5")
    
    // スタイル設定：サークル部分だけクリックを有効にする
    circle.style.transition = "all 1s ease"
    circle.style.cursor = "pointer"
    circle.style.opacity = "0"
    circle.style.pointerEvents = "auto" // 重要：サークル自体はクリックに反応させる

    circle.addEventListener("click", (e) => {
      e.stopPropagation() // 親要素へのクリック伝播を防止
      this.transitionToSelection(cx, cy)
    })

    this.svgTarget.appendChild(circle)
    setTimeout(() => circle.style.opacity = "1", 50)
  }

  transitionToSelection(cx, cy) {
    // 1. サークル内の画像を抽出（半径15%以内にあるか判定）
    const radius = 15; 
    const selectedPhotoIds = this.likedImages.filter(img => {
      const xKey = this.xSelectTarget.value;
      const yKey = this.ySelectTarget.value;
      const xPos = img.scores[xKey] || 50;
      const yPos = 100 - (img.scores[yKey] || 50); // Y軸は反転して計算

      // 中心点(cx, cy)からの距離を三平方の定理で計算
      const distance = Math.sqrt(Math.pow(xPos - cx, 2) + Math.pow(yPos - cy, 2));
      return distance <= radius;
    }).map(img => img.id);

    // 2. 全てのLike画像ID
    const allPhotoIds = this.likedImages.map(img => img.id).join(',');
    
    // 3. パラメータを構築（選抜されたIDを photo_ids として渡す）
    const url = `/my_styles/new?` + 
                `photo_ids=${selectedPhotoIds.join(',')}&` + 
                `all_photo_ids=${allPhotoIds}&` + 
                `genre_id=${this.genreIdValue}&` + 
                `cx=${Math.round(cx)}&` + 
                `cy=${Math.round(cy)}&` +
                `x_axis=${this.xSelectTarget.value}&` + // 振り返り用に現在の軸も渡す
                `y_axis=${this.ySelectTarget.value}`;
    
    window.location.href = url;
  }
  
  // 軸ラベルの表示更新
  updateLabels(xKey, yKey) {
    if (this.hasLabelXMinTarget) this.labelXMinTarget.innerText = this.labelMap[xKey][0]
    if (this.hasLabelXMaxTarget) this.labelXMaxTarget.innerText = this.labelMap[xKey][1]
    if (this.hasLabelYMaxTarget) this.labelYMaxTarget.innerText = this.labelMap[yKey][1]
    if (this.hasLabelYMinTarget) this.labelYMinTarget.innerText = this.labelMap[yKey][0]
  }
  
  // Fetch APIによるリクエスト送信の共通メソッド
  _sendRequest(url, method, body) {
    return fetch(url, {
      method: method,
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify(body)
    }).catch(error => console.error("Communication Error:", error))
  }
}