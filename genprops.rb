# From http://www.devdaily.com/blog/post/ruby/ruby-method-read-in-entire-file-as-string/
def get_file_as_string(filename)
    data = ''
    if ( FileTest.exists?(filename) )
        f = File.open(filename, "r") 
        f.each_line do |line|
            data += line
        end
    end
    return data
end


# This needs to be done more Ruby-like, but meh
items = (`find . -name '*.m' -print0`).split("\0").map { |x| x.gsub /^\.\//, '' }.map { |x| x.gsub /.m$/, '' }

classes = items.map do |fn|
    data = [["public",fn + ".h",get_file_as_string(fn + ".h")],["private",fn + ".m",get_file_as_string(fn + ".m")],["private",fn + "+Internal.h",get_file_as_string(fn + "+Internal.h")]];
    

    interfaces = data.map do |v|
        v[2].scan(/@interface.+?@end/m).map do |v|
            classname = "";
            addition = "";
            prop_defs = [];
            r = v.match(/@interface(?:\s+)(.+?(?:$|\{))(.+?)@end/m);
            if ( r == nil )
                nil
            else
                if ( rs = ( r[1].match(/^(.+?)(?:\s*):/ ) ) )
                    classname = rs[1];
                    addition = nil;
                elsif ( rs = ( r[1].match(/^(.+?)(?:\s*)\((.*?)\)/) ) )
                    classname = rs[1];
                    addition = rs[2];
                end
                prop_defs = r[2].scan(/@property.+;/).map do |v|
                    pr = v.match(/@property(?:\s+)(?:\((.+?)\))?(?:\s*)(?:__(?:weak|strong))?(?:\s*)([\w\<\>]+(?:\s*\*)?)(?:\s*)(.+);/);
                    {   :args => (pr[1] || "").split(/,/).map { |v| v.strip }.reject { |v| v.length == 0 },
                        :type => pr[2],
                        :name => pr[3] }
                end.inject({}) do |m,v|
                    m[v[:name]] = v;
                    m;
                end
                r[2].scan(/^\/\/ GENPROP.+$/).each do |v|
                    pr = v.match(/^\/\/ GENPROP (?:\((.+?)\)) (.+?)$/);
                    prop_defs[pr[2]] ||= {}
                    prop_defs[pr[2]][:extra] = (pr[1] || "").split(/\w*,\w*/).map { |v| v.strip }.reject { |v| v.length == 0 }
                 end
                {   :classname => classname,
                    :addition => addition,
                    :prop_defs => prop_defs };
            end
        end.reject { |v| v == nil || v[:prop_defs].size == 0 }.inject({}) do |m,v|
            cn = v[:classname]
            cv = (m[cn] ||= {})
            v[:prop_defs].each do |k,val|
                cv[k] ||= { :name => k, :args => [], :extra => [], :type => val[:type] }
                cv[k][:args] = cv[k][:args] + (val[:args] || [])
                cv[k][:extra] = cv[k][:extra] + (val[:extra] || [])
                if (cv[k][:type] != val[:type])
                    raise "#{cn}.#{k} redefined: #{cv[k][:type]} != #{val[:type]}"
                end
            end
            m
        end
    end.reject { |v| v == nil || v.length == 0 }.inject({}) do |m,v|
        v.each do |cn,iv|
            cv = (m[cn] ||= {})
            iv.each do |k,val|
                cv[k] ||= { :name => k, :args => [], :extra => [], :type => val[:type] }
                cv[k][:args] = cv[k][:args] + (val[:args] || [])
                cv[k][:extra] = cv[k][:extra] + (val[:extra] || [])
                if (cv[k][:type] != val[:type])
                    raise "#{cn}.#{k} redefined: #{cv[k][:type]} != #{val[:type]}"
                end
            end
        end
        m
    end
end.reject { |v| v == nil || v.length == 0 }.inject({}) do |m,v|
    v.each do |cn,iv|
        cv = (m[cn] ||= {})
        iv.each do |k,val|
            cv[k] ||= { :name => k, :args => [], :extra => [], :type => val[:type] }
            cv[k][:args] = cv[k][:args] + (val[:args] || [])
            cv[k][:extra] = cv[k][:extra] + (val[:extra] || [])
            if (cv[k][:type] != val[:type])
                raise "#{k} redefined: #{cv[k][:type]} != #{val[:type]}"
            end
        end
    end
    m
end.inject({}) do |m,(k,v)|
    v.each do |ok,ov|
        ag = v[ok][:args_raw] = ov[:args].inject({:raw => ov[:args]}) do |im,iv|
            im[iv] ||= :yes
            # now lets be smart here
            if (iv == "readwrite")
                im["readonly"] = :no
            end
            if (iv == "nonatomic")
                im["atomic"] = :no
            end
            if (iv == "retain" || iv == "copy")
                if (im[:rcv] && im[:rcv] != iv)
                    raise "#{k}.#{ok} mix of memory-managment types! #{iv} and #{im[:rcv]}"
                end
                im[:rcv] = iv
            end
            im
        end.inject({}) do |im,(ik,iv)| # remove bad ones
            if (iv == :yes)
                im[ik] = 1
            end
            im
        end
        # extract
        aext = {
            :writability => :readwrite,
            :semantics => :assign,
            :atomic => true,
        };
        if (ag["readonly"])
            aext[:writability] = :readonly
        end
        if (ag["retain"])
            aext[:semantics] = :retain
        elsif (ag["copy"])
            aext[:semantics] = :copy
        end
        if (ag["nonatomic"])
            aext[:atomic] = false
        end
        
        aext[:atomic] = false # FIXME, this is probably NOT a good idea to ignore!
        v[ok][:args] = aext
        
        # same with extra...
        ag = v[ok][:extra_raw] = ov[:extra].inject({}) do |im,iv|
            im[iv] ||= 1;
            im
        end
        v[ok][:extra] = {
            :setter => ag["no_setter"] ? false : true,
            :getter => ag["no_getter"] ? false : true,
            :kvc => ag["no_kvc"] ? false : true,
        }
    end
    m[k] = v
    m
end

f = File.open("Properties.m", "w")

f.print "#import \"Dreamwidth.h\"\n";

f.print "\n\n// THIS FILE IS AUTOGENERATED, DO NOT EDIT\n\n"
classes.each do |cn,props|
    f.print "@implementation #{cn} (GenProps)\n\n"
    props.each do |pn,data|
        e = data[:extra]
        a = data[:args]
        t = data[:type]
        if (e[:getter])
            st = a[:semantics];
            f.print " -(#{t})#{pn} {\n";
            if (a[:atomic])
                f.print "  [__lock lock];\n"
            end
            f.print "  return #{pn};\n";
            if (a[:atomic])
                f.print "  [__lock unlock];\n"
            end
            f.print " }\n";
        end
        if (e[:setter])
            st = a[:semantics];
            pn_u = pn[0].chr.upcase + pn[1..-1]
            f.print " -(void)set#{pn_u}:(#{t})__val {\n";
            if (e[:kvc])
                f.print "  [self willChangeValueForKey:@\"#{pn}\"];\n"
            end
            if (a[:atomic])
                f.print "  [__lock lock];\n"
            end
            if (st == :assign)
                f.print "  #{pn} = __val;\n"
            elsif (st == :retain)
                f.print "  if (__val != #{pn}) {\n"
                f.print "    [#{pn} release];\n"
                f.print "    #{pn} = [__val retain];\n";
                f.print "  }\n";
            elsif (st == :copy)
                f.print "  if (__val != #{pn}) {\n"
                f.print "    [#{pn} release];\n"
                f.print "    #{pn} = [__val copy];\n";
                f.print "  }\n";
            end
            if (a[:atomic])
                f.print "  [__lock unlock];\n"
            end
            if (e[:kvc])
                f.print "  [self didChangeValueForKey:@\"#{pn}\"];\n"
            end
            f.print " }\n";
        end
        f.print "\n";
    end
    f.print "@end\n\n"
end

f.close