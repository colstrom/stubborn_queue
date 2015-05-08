require 'bundler/setup'
require 'resilient_queue'

context 'queueing' do
  setup do
    @timeout = 1
    @queue = ResilientQueue.new name: 'test', timeout: @timeout
    @queue.db.clear
    @item = 'test_item'
  end

  should 'add and remove items' do
    assert_equal 1, @queue.enqueue(@item)
    id = @queue.dequeue
    assert_equal @item, @queue.lookup(id)
  end

  should 'requeue items that don\'t finish' do
    assert_equal 1, @queue.enqueue(@item)
    @queue.dequeue
    sleep (@timeout+1)
    assert_equal 2, @queue.enqueue(@item)
  end

  should 'be able to finish items and not requeue them' do
    assert_equal 1, @queue.enqueue(@item)
    id = @queue.dequeue
    @queue.finish id
    sleep (@timeout+1)
    assert_equal 1, @queue.enqueue(@item)
  end
end
