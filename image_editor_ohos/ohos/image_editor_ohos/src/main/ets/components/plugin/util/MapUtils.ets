import { common2D } from '@kit.ArkGraphics2D';
import { Offset } from '../mode/Offset';


export class MapUtils {
  static get<T>(map: Map<string, ESObject>, key: string, defaultValue: T): T {
    return map.has(key) && map.get(key) != undefined ? map.get(key) as T : defaultValue;
  }

  static getMap(map: Map<string, ESObject>, key: string,): Map<string, ESObject> {
    return MapUtils.get<Map<string, ESObject>>(map, key, new Map<string, ESObject>());
  }

  static getColor(map: Map<string, ESObject>): common2D.Color {
    return {
      alpha: MapUtils.get(map, 'a', 0),
      red: MapUtils.get(map, 'r', 0),
      green: MapUtils.get(map, 'g', 0),
      blue: MapUtils.get(map, 'b', 0),
    }
  }

  static getRect(map: Map<string, ESObject>): common2D.Rect {
    let left = MapUtils.get(map, 'left', 0);
    let top = MapUtils.get(map, 'top', 0);
    let width = MapUtils.get(map, 'width', 0);
    let height = MapUtils.get(map, 'height', 0);
    return {
      left: left,
      right: left + width,
      top: top,
      bottom: top + height,
    }
  }

  static getOffset(map: Map<string, ESObject>): Offset {
    return new Offset(map);
  }
}