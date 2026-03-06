import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ 
    "card", "deck", "swipeSection", "mappingSection", "controls", 
    "plottedCards", "svg", "xSelect", "ySelect",
    "labelXMin", "labelXMax", "labelYMin", "labelYMax"
  ]
  static values = { genreId: Number }

  connect() {
    this.currentIndex = 0
    this.likedImages = []
    this.labelMap = {
      'luxury_casual': ['親しみやすい', '高級感'],
      'natural_artificial': ['人工的', 'ナチュラル'],
      'simple_detail': ['シンプル', 'ディテール'],
      'soft_solid': ['クール', '優しい'],
      'tradition_modern': ['先進的', '伝統的'],
      'chic_pop': ['シック' , 'ポップ']
    }
    this.renderCard()
  }

  // カードの表示制御
  renderCard() {
    if (this.currentIndex >= this.cardTargets.length) {
      this.showMapping()
      return
    }
    this.cardTargets.forEach((card, index) => {
      card.classList.toggle("hidden", index !== this.currentIndex)
      card.style.opacity = index === this.currentIndex ? "1" : "0"
      card.style.pointerEvents = index === this.currentIndex ? "auto" : "none"
    })
  }

  // Like（右スワイプ / ハートボタン）: 作成・更新
  like() {
    const card = this.cardTargets[this.currentIndex]
    const photoId = card.dataset.id
    
    // サーバーへPOSTリクエスト（find_or_initialize_by + touch）
    this._sendRequest('/likes', 'POST', { photo_id: photoId })

    // 今回の診断セッション中のマッピング表示用にメモリに保持
    this.likedImages.push({
      id: photoId,
      url: card.dataset.imageUrl,
      scores: JSON.parse(card.dataset.scores)
    })
    this.next()
  }

  // Dislike（左スワイプ / バツボタン）: 削除
  dislike() {
    const card = this.cardTargets[this.currentIndex]
    const photoId = card.dataset.id

    // サーバーへDELETEリクエスト（もし過去のLikeがあれば消す）
    // ルーティングで設定した /likes/destroy_by_photo を叩く
    this._sendRequest('/likes/destroy_by_photo', 'DELETE', { photo_id: photoId })

    this.next()
  }

  // サーバー通信の共通メソッド
  _sendRequest(url, method, body) {
    fetch(url, {
      method: method,
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify(body)
    })
    .then(response => response.json())
    .then(data => {
      console.log(`Photo ${body.photo_id}: ${data.status}`)
    })
    .catch(error => {
      console.error("Communication Error:", error)
    })
  }

  next() {
    this.currentIndex++
    this.renderCard()
  }

  // マッピング画面への切り替え
  showMapping() {
    this.swipeSectionTarget.classList.add("hidden")
    this.mappingSectionTarget.classList.remove("hidden")
    if (this.hasControlsTarget) {
      this.controlsTarget.classList.remove("hidden")
    }
    this.updatePositions()
  }

  // 座標計算とラベルの更新
  updatePositions() {
    const xKey = this.xSelectTarget.value
    const yKey = this.ySelectTarget.value
    
    // ラベル更新
    if (this.hasLabelXMinTarget) this.labelXMinTarget.innerText = this.labelMap[xKey][0]
    if (this.hasLabelXMaxTarget) this.labelXMaxTarget.innerText = this.labelMap[xKey][1]
    if (this.hasLabelYMinTarget) this.labelYMinTarget.innerText = this.labelMap[yKey][1] // 下側
    if (this.hasLabelYMaxTarget) this.labelYMaxTarget.innerText = this.labelMap[yKey][0] // 上側

    this.plottedCardsTarget.innerHTML = ""
    const points = []

    this.likedImages.forEach((img, index) => {
      const item = document.createElement("div")
      item.className = "plotted-item w-[70px] h-[90px] absolute bg-cover bg-center border-2 border-white shadow-lg transition-all duration-1000"
      item.style.backgroundImage = `url(${img.url})`
      
      // 最初は中央に配置（配るアニメーションの起点）
      item.style.left = "50%"
      item.style.top = "50%"
      this.plottedCardsTarget.appendChild(item)

      // スコアに基づきアニメーションで各座標へ飛ばす
      setTimeout(() => {
        const xPos = img.scores[xKey] || 50
        const yPos = img.scores[yKey] || 50
        item.style.left = `${xPos}%`
        item.style.top = `${100 - yPos}%`
        item.style.transform = `translate(-50%, -50%) rotate(${Math.random() * 20 - 10}deg)`
        points.push({ x: xPos, y: 100 - yPos })
      }, 100 + (index * 50))
    })
  }
}
