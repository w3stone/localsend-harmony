import { NearbyDeviceModel } from '../../model';
import { relationalStore } from '@kit.ArkData';
import { LocalSendMapper } from './LocalSendMapper';
import { Connection, Wapper } from 'rdbplus';
import { Errors } from 'common';

const getRow = (res: relationalStore.ResultSet): NearbyDeviceModel => {
  const device: NearbyDeviceModel = new NearbyDeviceModel()
  device.id = res.getLong(res.getColumnIndex('id'))
  device.key = res.getString(res.getColumnIndex('key'))
  device.alias = res.getString(res.getColumnIndex('alias'))
  device.hostname = res.getString(res.getColumnIndex('hostname'))
  device.port = res.getLong(res.getColumnIndex('port'))
  device.fingerprint = res.getString(res.getColumnIndex('fingerprint'))
  device.isFavorited = res.getLong(res.getColumnIndex('isFavorited'))
  return device
}
const tbName: string = 't_device'

export class DeviceMapper extends LocalSendMapper<NearbyDeviceModel> {
  constructor() {
    super({ tableName: tbName, primaryKey: 'id' }, getRow)
  }

  private createTable(db: Connection): Promise<void> {
    const sql: string =
      `create table if not exists ${tbName}
        (
            id          integer primary key autoincrement,
            key         varchar(30),
            alias       varchar(50),
            hostname    varchar(15),
            port        integer,
            fingerprint varchar(100) UNIQUE,
            isFavorited INT
        );`
    return db.execDML(sql)
  }

  async insert(device: NearbyDeviceModel, conn?: Connection | undefined): Promise<void> {
    let _conn: Connection | null = null
    try {
      _conn = conn || await this.getConnection()
      await this.createTable(_conn)
      const sql: string = `insert into ${tbName} (id,key,alias,hostname,port,fingerprint,isFavorited) values (?,?,?,?,?,?,?);`
      await _conn.execDML(
        sql,
        [null, device.key, device.alias, device.hostname, device.port, device.fingerprint, device.isFavorited ? 1 : 0]
      )
    } catch (e) {
      console.error(`insertOrUpdate error : ${Errors.getErrorMessage(e)}`)
      throw Error(e)
    } finally {
      if (_conn !== conn && _conn != null) {
        await _conn.close()
      }
    }
  }

  async updateById(device: NearbyDeviceModel, conn?: Connection | undefined): Promise<void> {
    let _conn: Connection | null = null
    try {
      _conn = conn || await this.getConnection()
      await this.createTable(_conn)
      const sql: string = `update ${tbName} set key=?,alias=?,hostname=?,port=?,fingerprint=?,isFavorited=? where id = ?;`
      await _conn.execDML(
        sql,
        [device.key, device.alias, device.hostname, device.port, device.fingerprint, device.isFavorited ? 1 : 0, device.id]
      )
    } catch (e) {
      console.error(`insertOrUpdate error : ${Errors.getErrorMessage(e)}`)
      throw Error(e)
    } finally {
      if (_conn !== conn && _conn != null) {
        await _conn.close()
      }
    }
  }

  async insertOrUpdate(device: NearbyDeviceModel): Promise<NearbyDeviceModel> {
    const conn: Connection = await this.getConnection()
    try {
      await this.createTable(conn)
      const record = await this.getObject(new Wapper().eq('fingerprint', device.fingerprint), conn)
      if (record.length > 0) {
        device.id = record[0].id
        await this.updateById(device, conn)
      } else {
        await this.insert(device, conn)
        const record = await this.getObject(new Wapper().eq('fingerprint', device.fingerprint), conn)
        device.id = record[0].id
      }
      return device
    } catch (e) {
      console.error(`insertOrUpdate error : ${Errors.getErrorMessage(e)}`)
      throw Error(e)
    } finally {
      await conn.close()
    }
  }
}