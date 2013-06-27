require_dependency 'landable/asset'

module Landable
  class Attachments
    def initialize(owner)
      @owner = owner
    end

    def set(other)
      @owner.transaction do
        _scope.destroy_all
        other.to_hash.each do |name, asset|
          add asset, name
        end
      end
    end

    def add(asset, local_name = nil)
      attributes = { asset: asset, alias: local_name }
      if @owner.new_record?
        _scope.build attributes
      else
        _scope.create! attributes
      end
    end

    def delete(asset)
      _scope.where(asset_id: asset.id).destroy_all
    end

    def to_hash(key_prefix = nil)
      all = _scope.map do |att|
        [to_key(att, key_prefix), att.asset]
      end
      Hash[all]
    end

    private

    def _scope
      @owner.asset_attachments
    end

    def to_key(attachment, prefix)
      name = attachment.name
      if prefix.present?
        "#{prefix}/#{name}"
      else
        name
      end
    end
  end
end
