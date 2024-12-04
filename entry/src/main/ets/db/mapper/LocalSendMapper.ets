import { BaseMapper, MapperParam } from "rdbplus";
import { relationalStore } from "@kit.ArkData";

export class LocalSendMapper<T> extends BaseMapper<T> {
  constructor(params: MapperParam, getRow: (res: relationalStore.ResultSet) => T) {
    super(params, getRow, { name: 'localsend.db', securityLevel: relationalStore.SecurityLevel.S1 })
  }
}