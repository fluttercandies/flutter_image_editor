
export class FormatOption {
  constructor(map: Map<string, ESObject>) {
    this.format = map.get('format') as number;
    this.quality = map.get('quality') as number;
  }
  /// png 0
  /// jpeg 1
  format: number;
  quality: number;
}