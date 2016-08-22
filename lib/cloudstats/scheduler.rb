require 'rufus/scheduler'

module CloudStats
  class Scheduler
    attr_reader :publisher, :scheduler, :command_processor

    def initialize
      @publisher = Publisher.new
      @scheduler = create_scheduler
      @command_processor = CommandProcessor.new
    end

    def create_scheduler
      scheduler = Rufus::Scheduler.new
      def scheduler.on_error(job, error)
        $logger.error "#{error.class.name}: #{error.message}"
        Airbrake.catch(error, job_id: job.id)
      end
      scheduler
    end

    def schedule

      if !!PublicConfig['enable_remote_calls']
        $logger.info "Starting command processor"
        command_processor.run

        $logger.info "Scheduling command processor checker"
        scheduler.every '5s' do
          unless command_processor.alive?
            $logger.info "Command Processor is dead"
            command_processor.run
          end
        end
      end

      $logger.info "Scheduling reports every 1m"
      scheduler.every '1m' do
        publisher.publish(:statsd)
      end

      $logger.info "Scheduling http reports every 12 hours"
      scheduler.every '12h' do
        publisher.publish(:http)
      end

      $logger.info "Scheduling updates every #{update_rate}"
      scheduler.every update_rate do
        $logger.catch_and_log_socket_error(Updater.STORAGE_SERVICE) do
          Updater.new.update
        end
      end

      $logger.info "Scheduling backups"
      scheduler.cron '0 0 * * *' do
        CloudStats::Backup.instance.perform
      end

      scheduler.in '5m' do
        $logger.info 'Checking statsd_server'
        new_config = AgentApi.statsd_server

        if new_config['statsd_protocol'] == 'tcp'
          $logger.info 'Updating the statsd server'
          PublicConfig.merge!(new_config)
          PublicConfig.save_to_yml

          exit
        end
      end

      scheduler.join
    end

    private

    def update_rate
      PublicConfig['repo'] == 'agent007' ? '1m' : '5h'
    end
  end
end
