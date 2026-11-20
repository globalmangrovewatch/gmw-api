require "digest"

class ActiveStorage::Service::DatabaseService < ActiveStorage::Service
  class FileRecord < ActiveRecord::Base
    self.table_name = "active_storage_database_files"
  end

  def upload(key, io, checksum: nil, **)
    instrument :upload, key: key, checksum: checksum do
      data = io.read.to_s.b
      ensure_integrity!(data, checksum)
      record = FileRecord.find_or_initialize_by(key: key)
      record.data = data
      record.save!
    end
  end

  def download(key, &block)
    data = file_for(key).data
    if block
      instrument :streaming_download, key: key do
        yield data
      end
    else
      instrument :download, key: key do
        data
      end
    end
  end

  def download_chunk(key, range)
    instrument :download_chunk, key: key, range: range do
      file_for(key).data.byteslice(range)
    end
  end

  def delete(key)
    instrument :delete, key: key do
      FileRecord.where(key: key).delete_all
    end
  end

  def delete_prefixed(prefix)
    instrument :delete_prefixed, prefix: prefix do
      escaped = FileRecord.sanitize_sql_like(prefix)
      FileRecord.where("key LIKE ?", "#{escaped}%").delete_all
    end
  end

  def exist?(key)
    instrument :exist, key: key do |payload|
      answer = FileRecord.where(key: key).any?
      payload[:exist] = answer
      answer
    end
  end

  def compose(source_keys, destination_key, **)
    combined = source_keys.map { |source_key| file_for(source_key).data }.join.b
    upload(destination_key, StringIO.new(combined))
  end

  private

  def file_for(key)
    FileRecord.find_by(key: key) || raise(ActiveStorage::FileNotFoundError)
  end

  def ensure_integrity!(data, checksum)
    return if checksum.nil?
    return if Digest::MD5.base64digest(data) == checksum

    raise ActiveStorage::IntegrityError
  end
end
