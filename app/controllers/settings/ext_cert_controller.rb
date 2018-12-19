require "openssl"

# Settings::Ext_Cert allows users to install their own
# root certificate to generate other certificates
class Settings::ExtCertController < SettingsController
  def index
    set_instance_variables
  end

  def create
    # velum_cert_s = get_val_from_form(:external_certificate, :velum_cert)
    # velum_key_s = get_val_from_form(:external_certificate, :velum_key)
    # kubeapi_cert_s = get_val_from_form(:external_certificate, :kubeapi_cert)
    # kubeapi_key_s = get_val_from_form(:external_certificate, :kubeapi_key)
    # dex_cert_s = get_val_from_form(:external_certificate, :dex_cert)
    # dex_key_s = get_val_from_form(:external_certificate, :dex_key)
    # velum_cert_s = "velum_cert_s_"
    # velum_key_s = "velum_key_s_"
    # kubeapi_cert_s = "kubeapi_cert_s_"
    # kubeapi_key_s = "kubeapi_key_s_"
    # dex_cert_s = "dex_cert_s_"
    # dex_key_s = "dex_key_s_"

    key_cert_map_temp = key_cert_map
    key_cert_map_temp.keys.each do |i|
      return unless simple_validate(key_cert_map_temp[i])
      # p "$$$$$$$$$$$$$$$$$$$$$$"
      # p key_cert_map[i]
      # p "$$$$$$$$$$$$$$$$$$$$$$"
      # p ""
    end

    p key_cert_map_temp[:velum][:key][:key_string]

    # begin
    #   velum_cert = OpenSSL::X509::Certificate.new velum_cert_s
    #   velum_key = OpenSSL::PKey::RSA.new velum_key_s
    # rescue OpenSSL::X509::CertificateError
    #   set_instance_variables
    #   flash[:notice] = "Invalid Velum certificate, check format and try again"
    #   render action: :index, status: :unprocessable_entity
    #   return
    # rescue OpenSSL::PKey::RSAError
    #   set_instance_variables
    #   flash[:notice] = "Invalid Velum key, check format and try again"
    #   render action: :index, status: :unprocessable_entity
    #   return
    # end

    # unless velum_cert.verify(velum_key)
    #   set_instance_variables
    #   flash[:notice] = "Velum Cert/Key pair invalid"
    #   render action: :index, status: :unprocessable_entity
    #   return
    # end

    cert_map = {
      # external_cert_velum_cert:   velum_cert_s,
      external_cert_velum_cert:   key_cert_map_temp[:velum][:cert][:cert_string],
      external_cert_velum_key:    key_cert_map_temp[:velum][:key][:key_string],
      # external_cert_kubeapi_cert: kubeapi_cert_s,
      external_cert_kubeapi_cert: key_cert_map_temp[:kubeapi][:cert][:cert_string],
      external_cert_kubeapi_key:  key_cert_map_temp[:kubeapi][:key][:key_string],
      external_cert_dex_cert:     key_cert_map_temp[:dex][:cert][:cert_string],
      external_cert_dex_key:      key_cert_map_temp[:dex][:key][:key_string],
      # external_cert_dex_key:get_val_from_form(:external_certificate, :dex_key),
    }
    @errors = Pillar.apply cert_map
    if @errors.empty?
      redirect_to settings_ext_cert_index_path,
        notice: "External Certificate settings successfully saved." # + " ---#{cert_map}---"
      return
    else
      set_instance_variables
      render action: :index, status: :unprocessable_entity
    end
  end

  private

  def set_instance_variables
    # @velum = Pillar.value(pillar: :external_certificate_velum) || "Default value, remove later"
    # @kube_api = Pillar.value(pillar: :external_certificate_kube_api) || "Default value, remove later"
    # @dex = Pillar.value(pillar: :external_certificate_dex) || "Default value, remove later"
    # @velum_cert = cert_fingerprint(Pillar.value(pillar: :external_cert_velum_cert)) || "Default value, remove later"
    @velum_cert = Pillar.value(pillar: :external_cert_velum_cert) || "Default value, remove later"
    @velum_key = Pillar.value(pillar: :external_cert_velum_key) || "Default value, remove later"
    @kubeapi_key = Pillar.value(pillar: :external_cert_kubeapi_key) || "Default value, remove later"
    @kubeapi_cert = Pillar.value(pillar: :external_cert_kubeapi_cert) || "Default value, remove later"
    # @kubeapi_cert = cert_fingerprint(Pillar.value(pillar: :external_cert_kubeapi_cert)) || "Default value, remove later"
    @dex_cert = Pillar.value(pillar: :external_cert_dex_cert) || "Default value, remove later"
    @dex_key = Pillar.value(pillar: :external_cert_dex_key) || "Default value, remove later"
    # @abcd = Pillar.simple_pillars[:external_cert_velum_cert]
  end

  def get_val_from_form(form, param)
    if params[form][param].present?
      params[form][param].read.strip
    else
      ""
    end
  end

  def key_cert_map
    {
      velum:   {
        name: "Velum",
        cert: {
          cert_string:      get_val_from_form(:external_certificate, :velum_cert),
          pillar_model_key: :external_cert_velum_cert
        },
        key:  {
          key_string:       get_val_from_form(:external_certificate, :velum_key),
          pillar_model_key: :external_cert_velum_key
        }
      },
      kubeapi: {
        name: "Kubernetes API",
        cert: {
          cert_string:      get_val_from_form(:external_certificate, :kubeapi_cert),
          pillar_model_key: :external_cert_kubeapi_cert
        },
        key:  {
          key_string:       get_val_from_form(:external_certificate, :kubeapi_key),
          pillar_model_key: :external_cert_kubeapi_key
        }
      },
      dex:     {
        name: "Dex",
        cert: {
          cert_string:      get_val_from_form(:external_certificate, :dex_cert),
          pillar_model_key: :external_cert_dex_cert
        },
        key:  {
          key_string:       get_val_from_form(:external_certificate, :dex_key),
          pillar_model_key: :external_cert_dex_key
        }
      }
    }
  end

  def simple_validate(map)
    if map[:cert][:cert_string].empty? && map[:key][:key_string].empty?
      p "yoyoyo"
      true
    elsif map[:cert][:cert_string].empty? || map[:key][:key_string].empty?
      p "yoyoyo2"
      set_instance_variables
      flash[:notice] = "Error with #{map[:name]}, certificate and key must be uploaded together"
      render action: :index, status: :unprocessable_entity
      false
    else
      p "yoyoyo3"
      begin
        cert = OpenSSL::X509::Certificate.new map[:cert][:cert_string]
        key = OpenSSL::PKey::RSA.new map[:key][:key_string]
      rescue OpenSSL::X509::CertificateError
        set_instance_variables
        flash[:notice] = "Invalid #{map[:name]} certificate, check format and try again"
        render action: :index, status: :unprocessable_entity
        return false
      rescue OpenSSL::PKey::RSAError
        set_instance_variables
        flash[:notice] = "Invalid #{map[:name]} key, check format and try again"
        render action: :index, status: :unprocessable_entity
        return false
      end

      unless cert.verify(key)
        set_instance_variables
        flash[:notice] = "#{map[:name]} Certificate/Key pair invalid.  Ensure Certificate and Key are matching"
        render action: :index, status: :unprocessable_entity
        return false
      end
      true
    end
    # begin
    #   cert = OpenSSL::X509::Certificate.new map[:cert][:cert_string]
    #   key = OpenSSL::PKey::RSA.new map[:key][:key_string]
    # rescue OpenSSL::X509::CertificateError
    #   set_instance_variables
    #   flash[:notice] = "Invalid #{map[:name]} certificate, check format and try again"
    #   render action: :index, status: :unprocessable_entity
    #   return
    # rescue OpenSSL::PKey::RSAError
    #   set_instance_variables
    #   flash[:notice] = "Invalid #{map[:name]} key, check format and try again"
    #   render action: :index, status: :unprocessable_entity
    #   return
    # end

    # unless cert.verify(key)
    #   set_instance_variables
    #   flash[:notice] = "#{map[:name]} Certificate/Key pair invalid"
    #   render action: :index, status: :unprocessable_entity
    #   return
    # end
  end

  def cert_fingerprint(cert_string)
    cert = OpenSSL::X509::Certificate.new(cert_string)
    return "SHA256 Fingerprint: " + OpenSSL::Digest::SHA256.new(cert.to_der).to_s.scan(/../).map(&:upcase).join(":")
  rescue
    return "Could not calculate SHA256 fingerprint for the following:  #{cert_string[0, 30]}..."
  end

  def key_fingerprint(key_string)
    cert = OpenSSL::PKey::RSA.new(key_string)
    return "SHA256 Fingerprint: " + OpenSSL::Digest::SHA256.new(key.to_der).to_s.scan(/../).map(&:upcase).join(":")
  rescue
    return "Could not calculate SHA256 fingerprint for the following:  #{key_string[0, 30]}..."
  end
  # def ext_cert_params
  #   ret = {}
  #   params.require(
  #     :external_certificate
  #   ).permit(
  #     :velum,
  #     :kube_api,
  #     :dex
  #  ).each do |k, v|
  #   ret["external_certificate_#{k}".to_sym] = v.read.strip
  #   end
  #   ret
  # end
end
