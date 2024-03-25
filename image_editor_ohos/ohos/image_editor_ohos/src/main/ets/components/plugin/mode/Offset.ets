import { MapUtils } from '../util/MapUtils';

export class Offset {
  constructor(data: Map<string, ESObject>) {
    this.x = MapUtils.get(data, 'x', 0);
    this.y = MapUtils.get(data, 'y', 0);
  }

  x: number;
  y: number;
}
