module CloudStats
  def self.serialize(server_key, sysinfo)
    {
      version: CloudStats::VERSION,
      server_key: server_key,
      server: {
        remote_calls_enabled: !!PublicConfig['enable_remote_calls'],
        agent_version:   CloudStats::VERSION,
        services:        sysinfo.safe_get(:services),
        cpu_usage:       sysinfo.safe_get(:cpu, :usage),
        disk_used:       sysinfo.safe_get(:disk, :used),
        disk_size:       sysinfo.safe_get(:disk, :total),
        disk_used_perc:  sysinfo.safe_get(:disk, :used_perc),
        disk_used_free:  sysinfo.safe_get(:disk, :used_free),
        mem_used:        sysinfo.safe_get(:memory, :summary, :used),
        mem_free:        sysinfo.safe_get(:memory, :summary, :free),
        mem_cached:      sysinfo.safe_get(:memory, :cached),
        mem_buffers:     sysinfo.safe_get(:memory, :buffers),
        running_procs:   sysinfo.safe_get(:processes, :count),
        load_one:        sysinfo.safe_get(:cpu, :load, :one_minute),
        load_five:       sysinfo.safe_get(:cpu, :load, :five_minutes),
        load_fifteen:    sysinfo.safe_get(:cpu, :load, :fifteen_minutes),
        net_in:          sysinfo.safe_get(:network, :rx_speed),
        net_out:         sysinfo.safe_get(:network, :tx_speed),
        net_total:       sysinfo.safe_get(:network, :rx_speed) + sysinfo.safe_get(:network, :tx_speed),
        number_of_cpus:  sysinfo.safe_get(:cpu, :count),
        os:              sysinfo.safe_get(:os, :type),
        ps:              sysinfo.safe_get(:processes, :ps),
        blk_reads:       sysinfo.safe_get(:disk, :read_speed),
        blk_writes:      sysinfo.safe_get(:disk, :write_speed),
        uptime:          sysinfo.safe_get(:os, :uptime),
        uptime_seconds:  sysinfo.safe_get(:os, :uptime_seconds),
        users_count:     sysinfo.safe_get(:os, :users),
        connections_count: sysinfo.safe_get(:network, :connections_count),
        kernel:          sysinfo.safe_get(:os, :kernel),
        release:         "#{sysinfo.safe_get(:os, :name)} #{sysinfo.safe_get(:os, :version)}",
        pending_updates: sysinfo.safe_get(:os, :pending_updates),
        hostname:        sysinfo.safe_get(:network, :hostname),
        processes:       sysinfo.safe_get(:processes, :all),
        disks:           sysinfo.safe_get(:disk, :all),
        interfaces:      sysinfo.safe_get(:network, :all),
        vms:             sysinfo.safe_get(:openvz),
        disk_smart:      sysinfo.safe_get(:disk, :smart)
      }
    }
  end
end
