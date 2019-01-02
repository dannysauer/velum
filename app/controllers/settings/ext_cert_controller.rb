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
    velum_cert_string = Pillar.value(pillar: :external_cert_velum_cert)
    velum_key_string = Pillar.value(pillar: :external_cert_velum_key)
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

  def upload_validate(key_cert_map)
    # Do nothing if both cert/key are empty
    if key_cert_map[:cert][:cert_string].empty? && key_cert_map[:key][:key_string].empty?
      return true
    # Prevent upload unnless both cert/key are present
    elsif key_cert_map[:cert][:cert_string].empty? || key_cert_map[:key][:key_string].empty?
      set_instance_variables
      flash[:notice] = "Error with #{key_cert_map[:name]}, certificate and key must be uploaded together."
      render action: :index, status: :unprocessable_entity
      return false
    # Validate cert/key and verify that they match
    else
      cert = read_cert(key_cert_map[:cert][:cert_string])
      key = read_key(key_cert_map[:key][:key_string])

      # Check certificate valid format
      unless cert
        set_instance_variables
        flash[:notice] = "Invalid #{key_cert_map[:name]} certificate, check format and try again."
        render action: :index, status: :unprocessable_entity
        return false
      end

      # Check key valid format
      unless key
        set_instance_variables
        flash[:notice] = "Invalid #{key_cert_map[:name]} key, check format and try again."
        render action: :index, status: :unprocessable_entity
        return false
      end

      # Check that key matches certificate
      unless cert.verify(key)
        set_instance_variables
        flash[:notice] = "#{key_cert_map[:name]} Certificate/Key pair invalid.  Ensure Certificate and Key are matching."
        render action: :index, status: :unprocessable_entity
        return false
      end

      # Check that certificate date is valid
      if cert.not_after.to_s.strip.empty?
        return false
      elsif cert.not_before.to_s.strip.empty?
          return false
      elsif Time.now.to_i > cert.not_after.to_i
          return false
      elsif Time.now.to_i < cert.not_before.to_i
          return false
      end
      # return true

      # Everything's good!
      return true
    end
  end

  def cert_parse(cert_string)
    params = {}

    # Check if certificate exists, assume that validation has already occured
    if !cert_string
      params[:Error] = "Certificate not available, please upload a certificate"
      return params
    else
      cert = read_cert(cert_string)
      unless cert
        params[:Error] = "Failed to parse stored certificate, please check format and upload again"
        return params
      end
      params[:CommonName] = cert.issuer.to_a.select { |name, _data, _type| name == "CN" }.first[1]
      params[:Issuer] = cert.issuer.to_s.tr("/", " ")
      params[:Subject] = cert.subject.to_s.tr("/", " ")
      params[:SignatureAlgorithm] = cert.signature_algorithm
      params[:SerialNumber] = cert.serial
      params[:ValidNotBefore] = cert.not_before
      params[:ValidNotAfter] = cert.not_after
      begin
        fingerprint = OpenSSL::Digest::SHA256.new(cert.to_der)
        params[:SHA256Fingerprint] = fingerprint.to_s.scan(/../).map(&:upcase).join(":")
        return params
      rescue TypeError
        params[:Error] = "Failed to calculate Certificate fingerprint, please check format and upload again"
        return params
      end
    end
  end

  def key_parse(cert_string, key_string)
    params = {}
    # Check if key exists, assume that validation has already occured
    if !key_string# || !cert_string
      params[:Error] = "Key not available, please upload a key"
      return params
    elsif !cert_string
      params[:Error] = "Certificate not available, please upload a certificate"
      return params
    else
      cert = read_cert(cert_string)
      key = read_key(key_string)
      unless cert
        params[:Error] = "Failed to parse stored certificate, please check format and upload again"
        return params
      end
      unless key
        params[:Error] = "Failed to parse stored key, please check format and upload again"
        return params
      end

      params[:CertAndKeyMatch] = cert.check_private_key(key).to_s.titleize
      return params
    end
  end

  # Common method to build cert object from string
  def read_cert(cert_string)
    begin
      return OpenSSL::X509::Certificate.new(cert_string)
    rescue OpenSSL::X509::CertificateError
      # Push error handling to calling method for flexibility
      return nil
    end
  end

  # Common method to build key object from string
  def read_key(key_string)
    begin
      return OpenSSL::PKey::RSA.new(key_string)
    rescue OpenSSL::PKey::RSAError
      # Push error handling to calling method for flexibility
      return nil
    end
  end
  

  # def key_fingerprint(key_string)
  #   cert = OpenSSL::PKey::RSA.new(key_string)
  #   return "SHA256 Fingerprint: " + OpenSSL::Digest::SHA256.new(key.to_der).to_s.scan(/../).map(&:upcase).join(":")
  # rescue
  #   return "Could not calculate SHA256 fingerprint for the following:  #{key_string[0, 30]}..."
  # end
end
