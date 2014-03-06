class RemoveCollectionFromFavourites < ActiveRecord::Migration
  def change
    remove_reference :favourites, :collection, index: true
  end
end
