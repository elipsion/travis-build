module Travis
  module Build
    class Git
      class Tarball < Struct.new(:sh, :data)
        def apply
          sh.fold 'git.tarball' do
            mkdir
            download if tarball_url?
            dump if tarball_data
            extract
            cd
          end
        end

        private

          def mkdir
            sh.mkdir dir, echo: false, recursive: true
          end

          def download
            cmd  = "curl -o #{filename} #{auth_header}-L #{tarball_url}"
            echo = cmd.gsub(data.token || /\Za/, '[SECURE]')
            sh.cmd cmd, echo: echo, retry: true
          end

          def dump
            cmd = "base64 -d <<'_END' > #{filename} \n#{tarball_data}\n_END"
            echo = "Extracting #{filename}"
            sh.cmd cmd, echo: echo
          end

          def extract
            sh.cmd "tar xfz #{filename} --strip-components 1 -C #{dir}"
          end

          def cd
            sh.cd dir
          end

          def dir
            data.slug
          end

          def filename
            "#{basename}.tar.gz"
          end

          def basename
            data.slug.gsub('/', '-')
          end

          def tarball_url?
            data.api_url && data.commit
          end

          def tarball_url
            "#{data.api_url}/tarball/#{data.commit}"
          end

          def tarball_data
            data.tarball
          end

          def auth_header
            "-H \"Authorization: token #{data.token}\" " if data.token
          end
      end
    end
  end
end
