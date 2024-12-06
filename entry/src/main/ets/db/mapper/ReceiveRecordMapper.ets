import { Connection } from 'rdbplus';
import { LocalSendMapper } from './LocalSendMapper';
import { relationalStore } from '@kit.ArkData';
import { ReceiveRecordModel } from '../../model/ReceiveRecordModel';
import { Errors } from 'common';

const getRow = (res: relationalStore.ResultSet): ReceiveRecordModel => {
  const record: ReceiveRecordModel = new ReceiveRecordModel()
  record.id = res.getLong(res.getColumnIndex('id'))
  record.fileName = res.getString(res.getColumnIndex('fileName'))
  record.size = res.getLong(res.getColumnIndex('size'))
  record.fileType = res.getString(res.getColumnIndex('fileType'))
  record.sender = res.getString(res.getColumnIndex('sender'))
  record.sendAt = res.getLong(res.getColumnIndex('sendAt'))
  record.filePath = res.getString(res.getColumnIndex('filePath'))
  return record
}
const tbName: string = 't_record'

export class ReceivedRecordMapper extends LocalSendMapper<ReceiveRecordModel> {

  constructor() {
    super({ tableName: tbName, primaryKey: 'id' }, getRow)
  }

  private createTable(db: Connection): Promise<void> {
    const sql: string =
      `create table if not exists ${tbName}
        (
            id          integer primary key autoincrement,
            fileName    varchar(100),
            size        integer,
            fileType    varchar(100),
            sender      varchar(100),
            sendAt      integer,
            filePath    varchar(300)
        );`
    return db.execDML(sql)
  }

  async insert(obj: ReceiveRecordModel, conn?: Connection | undefined): Promise<void> {
    let _conn: Connection | null = null
    try {
      _conn = conn || await this.getConnection()
      await this.createTable(_conn)
      await super.insert(obj, _conn)
    } catch (e) {
      console.error(`insert error : ${Errors.getErrorMessage(e)}`)
      throw Error(e)
    } finally {
      if (_conn !== conn && _conn != null) {
        await _conn.close()
      }
    }
  }
}