import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "mainView", "mapView", "nameDisplay", "nameInput", "editInterface", 
    "plottedCards", "svg", "xSelect", "ySelect", "circleContainer",
    "labelXMin", "labelXMax", "labelYMin", "labelYMax"
  ]
  static values = { 
    styleId: Number,
    allPhotos: Array,
    initialCx: Number,
    initialCy: Number
  }

  connect() {
    this.labelMap = {
      'luxury_casual': ['親しみやすい', '高級感'],
      'natural_artificial': ['人工的', 'ナチュラル感'],
      'simple_detail': ['シンプル', 'ディテール'],
      'soft_solid': ['クール', '柔らかい・優しい'],
      'classic_modern': ['先進的', '伝統的'],
      'chic_pop': ['シック', 'ポップ']
    }
  }

  showMap() {
    this.mainViewTarget.classList.add("hidden")
    this.mapViewTarget.classList.remove("hidden")
    this.updatePositions()
  }

  hideMap() {
    this.mapViewTarget.classList.add("hidden")
    this.mainViewTarget.classList.remove("hidden")
  }

  toggleEdit() {
    this.nameDisplayTarget.classList.toggle("hidden")
    this.editInterfaceTarget.classList.toggle("hidden")
  }

  async updateName() {
    const newName = this.nameInputTarget.value
    try {
      const response = await fetch(`/my_styles/${this.styleIdValue}`, {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify({ my_style: { custom_name: newName } })
      })
      if (response.ok) {
        this.nameDisplayTarget.querySelector('h1').innerText = newName
        this.toggleEdit()
      }
    } catch (error) {
      alert("名前の更新に失敗しました")
    }
  }

  updatePositions() {
    // 1. サークルをフェードアウト
    if (this.hasCircleContainerTarget) {
      this.circleContainerTarget.classList.replace("opacity-100", "opacity-0")
    }

    const xKey = this.xSelectTarget.value
    const yKey = this.ySelectTarget.value
    this.updateLabels(xKey, yKey)
    this.plottedCardsTarget.innerHTML = ""

    const points = []

    this.allPhotosValue.forEach((img, index) => {
      const item = document.createElement("div")
      item.className = "absolute w-12 h-16 bg-cover bg-center border border-white shadow-sm transition-all duration-1000 ease-out"
      item.style.backgroundImage = `url(${img.url})`
      
      const xPos = img.scores[xKey] || 50
      const yPos = img.scores[yKey] || 50
      
      item.style.left = "50%"
      item.style.top = "50%"
      item.style.opacity = "0"
      this.plottedCardsTarget.appendChild(item)

      points.push({ x: xPos, y: 100 - yPos })

      setTimeout(() => {
        item.style.left = `${xPos}%`
        item.style.top = `${100 - yPos}%`
        item.style.opacity = "1"
        item.style.transform = `translate(-50%, -50%)`
      }, 50 + (index * 20))
    })

    // カード移動完了後にクラスター分析とフェードイン
    setTimeout(() => this.analyzeClusters(points), 1000)
  }

  analyzeClusters(points) {
    if (points.length === 0) return
    const grid = Array.from({ length: 8 }, () => Array(6).fill(0))
    points.forEach(p => {
      const col = Math.min(Math.floor(p.x / (100 / 8)), 7)
      const row = Math.min(Math.floor(p.y / (100 / 6)), 5)
      grid[col][row]++
    })

    let maxCount = 0
    let bestArea = { col: 4, row: 3 }
    for (let c = 0; c < 8; c++) {
      for (let r = 0; r < 6; r++) {
        if (grid[c][r] > maxCount) {
          maxCount = grid[c][r]
          bestArea = { col: c, row: r }
        }
      }
    }

    const areaPoints = points.filter(p => {
      const c = Math.min(Math.floor(p.x / (100 / 8)), 7)
      const r = Math.min(Math.floor(p.y / (100 / 6)), 5)
      return c === bestArea.col && r === bestArea.row
    })

    const avgX = areaPoints.reduce((sum, p) => sum + p.x, 0) / areaPoints.length
    const avgY = areaPoints.reduce((sum, p) => sum + p.y, 0) / areaPoints.length
    
    this.drawCircle(avgX, avgY)
    
    // フェードイン
    if (this.hasCircleContainerTarget) {
      this.circleContainerTarget.classList.replace("opacity-0", "opacity-100")
    }
  }
  
  updateLabels(xKey, yKey) {
    if (this.hasLabelXMinTarget) this.labelXMinTarget.innerText = this.labelMap[xKey][0]
    if (this.labelXMaxTarget) this.labelXMaxTarget.innerText = this.labelMap[xKey][1]
    if (this.labelYMaxTarget) this.labelYMaxTarget.innerText = this.labelMap[yKey][1]
    if (this.labelYMinTarget) this.labelYMinTarget.innerText = this.labelMap[yKey][0]
  }

  drawCircle(cx, cy) {
    if (!this.hasSvgTarget) return
    this.svgTarget.innerHTML = `<circle cx="${cx}%" cy="${cy}%" r="15%" fill="rgba(212, 163, 115, 0.2)" stroke="#d4a373" stroke-width="2" stroke-dasharray="4,4" />`
  }
}