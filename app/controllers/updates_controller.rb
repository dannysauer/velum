require "velum/salt"

# UpdatesController handles all the interaction with the updates of all nodes.
class UpdatesController < ApplicationController
  before_action :admin_needs_update, only: :create

  # Reboot the admin node.
  def create
    # rubocop:disable SkipsModelValidations
    Minion.admin.update_all highstate: Minion.highstates[:applied], tx_update_reboot_needed: false
    # rubocop:enable SkipsModelValidations
    ::Velum::Salt.call(
      action:  "cmd.run",
      targets: "admin",
      arg:     "systemctl reboot"
    )

    render json: { status: "rebooting" }
  end

  protected

  def admin_needs_update
    render json: { status: "unknown" } if Minion.where(role: Minion.roles[:admin])
                                                .needs_update.count.zero?
  end
end
