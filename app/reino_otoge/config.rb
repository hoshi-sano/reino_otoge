module ReinoOtoge
  module Config
    module ModuleMethods
      DEFAULT = {
        live_keys: [K_Z, K_X, K_C, K_V, K_B],
      }

      def personal(key)
        config_file_path = File.join(CONFIG_DIR, "#{key}.yml")
        if File.exist?(config_file_path)
          YAML.load_file(config_file_path).map { |str| DXRuby.const_get(str) }
        else
          nil
        end
      end

      def live_keys
        @live_keys ||= (personal(:live_keys) || DEFAULT[:live_keys])
      end

      def live_key_chars
        live_keys.map { |val| SELECTABLE_KEYS.key(val) }
      end

      def live_keys=(ary)
        @live_keys = ary
        personal_conf = live_key_chars.map { |c| "K_#{c}" }
        File.open(File.join(CONFIG_DIR, 'live_keys.yml'), 'w') do |f|
          YAML.dump(personal_conf, f)
        end
      end
    end
    extend ModuleMethods
  end
end
