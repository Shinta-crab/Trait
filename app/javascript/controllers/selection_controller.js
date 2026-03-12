import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["nameInput"]
  static values = {
    photoIds: String,    // 選抜された画像（サークル内）
    allPhotoIds: String, // 全てのLike画像
    genreId: Number,
    cx: Number,
    cy: Number,
    xAxis: String,
    yAxis: String
  }

  // 保存ボタンがクリックされた時の処理
  save(event) {
    event.preventDefault()

    const styleName = this.nameInputTarget.value
    const photoIds = this.photoIdsValue
    const genreId = this.genreIdValue

    fetch('/my_styles', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
      },
	    body: JSON.stringify({ 
	      custom_name: styleName,
	      photo_ids: this.photoIdsValue,      // 選抜
	      all_photo_ids: this.allPhotoIdsValue, // 全て
	      genre_id: this.genreIdValue,
	      cx: this.cxValue,
	      cy: this.cyValue,
	      x_axis: this.xAxisValue,
	      y_axis: this.yAxisValue
	    })
    })
    .then(async response => {
      const data = await response.json()
      
      if (response.status === 401) {
        alert("保存するにはログインが必要です。")
        window.location.href = '/users/sign_up'
      } else if (response.ok) {
        window.location.href = data.redirect_url
      } else {
        alert("エラーが発生しました: " + (data.message || "不明なエラー"))
      }
    })
    .catch(error => {
      console.error("Error:", error)
      alert("通信に失敗しました。")
    })
  }
}