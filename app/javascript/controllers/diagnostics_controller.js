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
      'natural_artificial': ['人工的', 'ナチュラル感'],
      'simple_detail': ['シンプル', 'ディテール'],
      'soft_solid': ['クール', '柔らかい・優しい'],
      'tradition_modern': ['先進的', '伝統的'],
      'chic_pop': ['ポップ', 'シック']
    }
    this.keydownHandler = this.handleKeydown.bind(this)
    window.addEventListener("keydown", this.keydownHandler)
    this.renderCard()
  }

  disconnect() {
    window.removeEventListener("keydown", this.keydownHandler)
  }

  handleKeydown(event) {
    if (this.swipeSectionTarget.classList.contains("hidden")) return

    if (event.key === "ArrowRight") {
      this.like()
    } else if (event.key === "ArrowLeft") {
      this.dislike()
    }
  }

  renderCard() {
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
        if (card.dataset.imageUrl) {
          card.style.backgroundImage = `url(${card.dataset.imageUrl})`
        }
      } else {
        card.style.opacity = "0"
        card.style.pointerEvents = "none"
      }
    })
  }

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

  dislike() {
    const card = this.cardTargets[this.currentIndex]
    this._sendRequest('/likes/destroy_by_photo', 'DELETE', { photo_id: card.dataset.id })
    this.next()
  }

  next() {
    this.currentIndex++
    this.renderCard()
  }

  showMapping() {
    this.swipeSectionTarget.classList.add("hidden")
    this.mappingSectionTarget.classList.remove("hidden")
    if (this.hasControlsTarget) {
      this.controlsTarget.classList.remove("hidden")
    }

    const xKey = this.xSelectTarget.value
    const yKey = this.ySelectTarget.value
    this.updateLabels(xKey, yKey)

    this.plottedCardsTarget.innerHTML = ""

    this.likedImages.forEach((img, index) => {
      const item = document.createElement("div")
      item.className = "plotted-item w-[70px] h-[90px] absolute bg-cover bg-center border-2 border-white shadow-lg transition-all duration-1000 ease-out"
      item.id = `plotted-${img.id}`
      item.style.backgroundImage = `url(${img.url})`
      item.style.left = "50%"
      item.style.top = "50%"
      item.style.transform = "translate(-50%, -50%) rotate(0deg)"
      
      this.plottedCardsTarget.appendChild(item)

      setTimeout(() => {
        const xPos = img.scores[xKey] || 50
        const yPos = img.scores[yKey] || 50
        item.style.left = `${xPos}%`
        item.style.top = `${100 - yPos}%`
        item.style.transform = `translate(-50%, -50%) rotate(${Math.random() * 20 - 10}deg)`
      }, 100 + (index * 80))
    })

    setTimeout(() => {
      this.updatePositions()
    }, 100 + (this.likedImages.length * 80) + 1000)
  }

  updatePositions() {
    const xKey = this.xSelectTarget.value
    const yKey = this.ySelectTarget.value
    this.updateLabels(xKey, yKey)

    const points = []

    this.likedImages.forEach((img) => {
      const item = document.getElementById(`plotted-${img.id}`)
      if (!item) return

      const xPos = img.scores[xKey] || 50
      const yPos = img.scores[yKey] || 50

      item.style.left = `${xPos}%`
      item.style.top = `${100 - yPos}%`
      item.style.transform = `translate(-50%, -50%) rotate(${Math.random() * 10 - 5}deg)`
      
      points.push({ x: xPos, y: 100 - yPos })
    })

    setTimeout(() => {
      this.analyzeClusters(points)
    }, 1200)
  }

  analyzeClusters(points) {
    if (points.length === 0) return
    this.svgTarget.innerHTML = ""

    const grid = Array.from({ length: 3 }, () => Array(4).fill(0))

    points.forEach(p => {
      const col = Math.min(Math.floor(p.x / (100 / 3)), 2)
      const row = Math.min(Math.floor(p.y / (100 / 4)), 3)
      grid[col][row]++
    })

    let maxCount = 0
    let bestArea = { col: 1, row: 1 }

    for (let c = 0; c < 3; c++) {
      for (let r = 0; r < 4; r++) {
        if (grid[c][r] > maxCount) {
          maxCount = grid[c][r]
          bestArea = { col: c, row: r }
        }
      }
    }

    const areaPoints = points.filter(p => {
      const c = Math.min(Math.floor(p.x / (100 / 3)), 2)
      const r = Math.min(Math.floor(p.y / (100 / 4)), 3)
      return c === bestArea.col && r === bestArea.row
    })

    const avgX = areaPoints.reduce((sum, p) => sum + p.x, 0) / areaPoints.length
    const avgY = areaPoints.reduce((sum, p) => sum + p.y, 0) / areaPoints.length

    this.drawCircle(avgX, avgY)
  }

  drawCircle(cx, cy) {
    const circle = document.createElementNS("http://www.w3.org/2000/svg", "circle")
    circle.setAttribute("cx", `${cx}%`)
    circle.setAttribute("cy", `${cy}%`)
    circle.setAttribute("r", "15%")
    circle.setAttribute("fill", "rgba(212, 163, 115, 0.4)")
    circle.setAttribute("stroke", "#d4a373")
    circle.setAttribute("stroke-width", "3")
    circle.setAttribute("stroke-dasharray", "5,5")
    circle.style.transition = "all 1s ease"
    circle.style.cursor = "pointer"
    circle.style.opacity = "0"

    // 🆕 クリックイベント：ER図に基づいた保存処理を実行
    circle.addEventListener("click", () => {
      this.saveAnalysisResult(cx, cy)
    })

    this.svgTarget.appendChild(circle)
    setTimeout(() => circle.style.opacity = "1", 50)
  }

  // 🆕 本番ER図に基づいた保存ロジック
  saveAnalysisResult(cx, cy) {
    if (!confirm("このスタイルを「My Style」として保存しますか？")) return

    // MyStyleSelections 用に基準軸スコアを含めたデータを作成
    const selections = this.likedImages.map(img => ({
      photo_id: img.id,
      pos_x: Math.round(img.scores['simple_detail'] || 50),
      pos_y: Math.round(img.scores['soft_solid'] || 50)
    }))

    const payload = {
      genre_id: this.genreIdValue,
      selections: selections
      // 必要に応じて cx, cy (12分割エリアの中心) も送信可能
    }

    this._sendRequest('/analysis_results', 'POST', payload)
      .then(response => {
        if (response.ok) {
          window.location.href = "/my_styles" // 保存後の遷移先
        } else {
          alert("保存に失敗しました。")
        }
      })
  }

  updateLabels(xKey, yKey) {
    if (this.hasLabelXMinTarget) this.labelXMinTarget.innerText = this.labelMap[xKey][0]
    if (this.hasLabelXMaxTarget) this.labelXMaxTarget.innerText = this.labelMap[xKey][1]
    if (this.hasLabelYMaxTarget) this.labelYMaxTarget.innerText = this.labelMap[yKey][1]
    if (this.hasLabelYMinTarget) this.labelYMinTarget.innerText = this.labelMap[yKey][0]
  }

  _sendRequest(url, method, body) {
    return fetch(url, {
      method: method,
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      },
      body: JSON.stringify(body)
    })
    .catch(error => console.error("Communication Error:", error))
  }
}
