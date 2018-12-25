require "openssl"

# Settings::Ext_Cert allows users to install their own SSL Certificates
# and Private Keys for encrypted external communication
class Settings::ExtCertController < SettingsController
  def index
    set_instance_variables
  end

  def create
    key_cert_map_temp = key_cert_map
    key_cert_map_temp.keys.each do |i|
      return unless upload_validate(key_cert_map_temp[i])
    end

    cert_map = {
      external_cert_velum_cert:   key_cert_map_temp[:velum][:cert][:cert_string],
      external_cert_velum_key:    key_cert_map_temp[:velum][:key][:key_string],
      external_cert_kubeapi_cert: key_cert_map_temp[:kubeapi][:cert][:cert_string],
      external_cert_kubeapi_key:  key_cert_map_temp[:kubeapi][:key][:key_string],
      external_cert_dex_cert:     key_cert_map_temp[:dex][:cert][:cert_string],
      external_cert_dex_key:      key_cert_map_temp[:dex][:key][:key_string]
    }
    @errors = Pillar.apply cert_map
    if @errors.empty?
      redirect_to settings_ext_cert_index_path,
        notice: "External Certificate settings successfully saved."
      return
    else
      set_instance_variables
      render action: :index, status: :unprocessable_entity
    end
  end

  private

  def set_instance_variables
    # @velum_cert = Pillar.value(pillar: :external_cert_velum_cert) || "Default value, remove later"
    velum_cert_string = Pillar.value(pillar: :external_cert_velum_cert)
    velum_key_string = Pillar.value(pillar: :external_cert_velum_key) #:external_cert_velum_key)
    @velum_cert = cert_parse(velum_cert_string)
    @velum_key = key_parse(velum_cert_string, velum_key_string)

    @kubeapi_cert = Pillar.value(pillar: :external_cert_kubeapi_cert) || "Default value, remove later"
    @kubeapi_key = Pillar.value(pillar: :external_cert_kubeapi_key) || "Default value, remove later"
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

  def upload_validate(map)
    if map[:cert][:cert_string].empty? && map[:key][:key_string].empty?
      true
    elsif map[:cert][:cert_string].empty? || map[:key][:key_string].empty?
      set_instance_variables
      flash[:notice] = "Error with #{map[:name]}, certificate and key must be uploaded together."
      render action: :index, status: :unprocessable_entity
      false
    else
      begin
        cert = OpenSSL::X509::Certificate.new map[:cert][:cert_string]
        key = OpenSSL::PKey::RSA.new map[:key][:key_string]
      rescue OpenSSL::X509::CertificateError
        set_instance_variables
        flash[:notice] = "Invalid #{map[:name]} certificate, check format and try again."
        render action: :index, status: :unprocessable_entity
        return false
      rescue OpenSSL::PKey::RSAError
        set_instance_variables
        flash[:notice] = "Invalid #{map[:name]} key, check format and try again."
        render action: :index, status: :unprocessable_entity
        return false
      end

      unless cert.verify(key)
        set_instance_variables
        flash[:notice] = "#{map[:name]} Certificate/Key pair invalid.  Ensure Certificate and Key are matching."
        render action: :index, status: :unprocessable_entity
        return false
      end
      true
    end
  end

  # Parse Certificate and get information.
  def cert_parse(cert_string)
    params = {}
    if !cert_string
      params[:Error] = "Certificate not available, please upload a certificate"
      return params
    else
      begin
        certpem = OpenSSL::X509::Certificate.new(cert_string)
        params[:CommonName] = certpem.issuer.to_a.select { |name, _data, _type| name == "CN" }.first[1]
        params[:Issuer] = certpem.issuer.to_s.gsub("/", " ")
        params[:Subject] = certpem.subject.to_s.gsub("/", " ")
        params[:SignatureAlgorithm] = certpem.signature_algorithm
        params[:SerialNumber] = certpem.serial
        params[:ValidNotBefore] = certpem.not_before
        params[:ValidNotAfter] = certpem.not_after

        fingerprint = OpenSSL::Digest::SHA256.new(certpem.to_der)
        params[:SHA256Fingerprint] = fingerprint.to_s.scan(/../).map(&:upcase).join(":")
        return params
      rescue TypeError
        params[:Error] = "Failed to calculate Certificate fingerprint, please check format and upload again"
        return params
      rescue OpenSSL::X509::CertificateError
        params[:Error] = "Failed to parse stored certificate, please check format and upload again"
        return params
      end
    end
  end

  def key_parse(cert_string, key_string)
    params = {}
    if !key_string || !cert_string
      params[:Error] = "Key not available, please upload a key"
      return params
    else
      begin
        cert = OpenSSL::X509::Certificate.new(cert_string)
        key = OpenSSL::PKey::RSA.new(key_string)
        params[:CertAndKeyMatch] = cert.check_private_key(key).to_s.titleize
        return params
      rescue OpenSSL::X509::CertificateError
        params[:Error] = "Failed to parse stored certificate, please check format and upload again"
        return params
      rescue OpenSSL::PKey::RSAError
        params[:Error] = "Failed to parse stored key, please check format and upload again"
        return params
      end
    end
  end

  # # To get fingerprint from certificate
  # def cert_fingerprint(certpem)
  #   fp = OpenSSL::Digest::SHA256.new(certpem.to_der).to_s
  #   return fp
  # rescue TypeError
  #   raise TypeError
  # end

  # def read_cert(cert_string)
  #   return OpenSSL::X509::Certificate.new cert_string
  # rescue OpenSSL::X509::CertificateError
  #   raise OpenSSL::X509::CertificateError
  # end

  # def read_key(key_string)
  #   return OpenSSL::PKey::RSA.new key_string
  # rescue OpenSSL::PKey::RSAError
  #   raise OpenSSL::PKey::RSAError
  # end

  # def cert_fingerprint(cert_string)
  #   cert = OpenSSL::X509::Certificate.new(cert_string)
  #   return "SHA256 Fingerprint: " + OpenSSL::Digest::SHA256.new(cert.to_der).to_s.scan(/../).map(&:upcase).join(":")
  # rescue
  #   return "Could not calculate SHA256 fingerprint for the following:  #{cert_string[0, 30]}..."
  # end

  # def key_fingerprint(key_string)
  #   cert = OpenSSL::PKey::RSA.new(key_string)
  #   return "SHA256 Fingerprint: " + OpenSSL::Digest::SHA256.new(key.to_der).to_s.scan(/../).map(&:upcase).join(":")
  # rescue
  #   return "Could not calculate SHA256 fingerprint for the following:  #{key_string[0, 30]}..."
  # end
end
