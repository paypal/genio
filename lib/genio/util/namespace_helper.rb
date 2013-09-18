module Genio
  module Util
    module NamespaceHelper

      # Checks the format of the namespace as uri or urn,
      # and converts the namespace to package name ('.' seperated)
      # eg: http://github.paypal.com/payments/sale is changed to
      # com.paypal.github.payments.sale
      # eg: urn:ebay:apis:eBLBaseComponents is changed to
      # urn.ebay.apis.eBLBaseComponents
      # any numbers occuring as a part of path in the uri
      # based namespaces is removed
      def convert_ns_to_package(ns)
        if is_urn_ns(ns)
          packagename = ns.gsub(/:/, "\.")
        else
          hostname = URI.parse(ns)
          packagename = hostname.host.sub(/^www./, "").split(".").reverse.join(".")
          packagename << hostname.path.to_s.gsub(/[\d-]+/, "").sub(/\/+$/,'').gsub(/-/, '_').gsub(/\/+/, ".")
        end
        packagename
      end

      # Strips a package name off any
      # Top Level Domains (TLD)s; com, co, org, gov, de, us, in
      # eg: com.paypal.github.payments.sale is converted to
      # paypal.github.payments.sale
      def remove_tld_in_package(packagename)
        packagename.sub(/^(com|co|org|gov|de|us|in)\./, "")
      end

      # Lowercases parts of a package name
      # eg: Paypal.Github.Payments.Sale is converted to
      # paypal.github.payments.sale
      def lowercase_package(packagename)
        packagename.gsub(/([^\.]+[\.]?)/){ |match| $1.camelcase(:lower) }
      end

      # Capitalizes parts of a package name
      # eg: paypal.github.payments.sale is converted to
      # Paypal.Github.Payments.Sale
      def capitalize_package(packagename)
        packagename.gsub(/([^\.]+[\.]?)/){ |match| $1.camelcase }
      end

      # Returns a folder path corresponding to the
      # packagename; setting capitalize_folder true returns
      # folder names that are captialized
      def get_package_folder(packagename, capitalize_folder = false)
        if (capitalize_folder)
          capitalize_package(packagename).gsub(/\.|\\/, '/')
        else
          packagename.gsub(/\.|\\/, '/')
        end
      end

	  # Returns a namespace path with '\' corresponding to the
      # packagename; setting capitalizefolder true returns
      #  names that are captialized
      def get_slashed_package_name(packagename, capitalizefolder = false)
        if (capitalizefolder)
          capitalize_package(packagename).gsub(/\./, '\\')
        else
          packagename.gsub(/\./, '\\')
        end
      end

      # Checks if the uri starts with protocol
      # schemes and returns true, else treats
      # the namespace as a Uniform Resource Name
      def is_urn_ns(ns)
        !ns.start_with?('http:','https:')
      end

    end
  end
end
