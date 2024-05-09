export class ImageUtils {
  static calcScale(minWidth: number, minHeight: number, width: number, height: number,): number {
    let scaleW = width / minWidth
    let scaleH = height / minHeight
    //if (this.showLog) {
    console.log(`width scale = ${scaleW}`)
    console.log(`height scale = ${scaleH}`)
    //}
    return Math.max(1, Math.min(scaleW, scaleH))
  }

  // 1	上	左	0°
  // 2	上	右	水平翻转
  // 3	下	右	180°
  // 4	下	左	垂直翻转
  // 5	左	上	顺时针90°+水平翻转
  // 6	右	上	顺时针90°
  // 7	右	下	顺时针90°+垂直翻转
  // 8	左	下	逆时针90°
  static parseExifRotate(orientation: string): number {
    orientation = orientation.toLowerCase();
    switch (orientation) {
    // 1	上	左	0°
      case 'top-left':
        return 0;
    // 2	上	右	水平翻转
      case 'top-right':
        return 0;
    // 3	下	右	180°
      case 'bottom-right':
        return 180;
    // 4	下	左	垂直翻转
      case 'bottom-left':
        return 0;
      case 'left-top':
      // 5	左	上	顺时针90°+水平翻转
        return 90;
    // 6	右	上	顺时针90°
      case 'right-top':
        return 90;
    // 7	右	下	顺时针90°+垂直翻转
      case 'right-bottom':
        return 90;
    // 8	左	下	逆时针90°
      case 'left-bottom':
        return 270;
      default:
        break;
    }
    return 0;
  }
}